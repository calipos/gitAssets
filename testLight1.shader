// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/testLight1"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _GradMap("Gradient Map", 2D) = "white" {} //The thicker the smoke, the more visible shadow.
        _GradPow("Gradient Power", Range(0,2)) = 1 //This line can be removed if you have no intention to animate gradient power.
        _AmbientPow("Ambient Power", Range(0,1)) = 0.5 // Can be used in HDR effect. Intensity greater than 2 causes glitch in HDR rendering.
        _Glow("Intensity", Range(0,10)) = 1
    }
        SubShader
        {
            Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "LightMode" = "ForwardBase" "PreviewType" = "Plane"}
            LOD 100
            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"
                #include "UnityLightingCommon.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 texcoord : TEXCOORD0;
                    float4 normal : NORMAL;
                    float4 tangent : TANGENT;
                    fixed4 color : COLOR;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                struct v2f
                {
                    float4 vertex : SV_POSITION;
                    float4 uv : TEXCOORD0;
                    fixed4 color : COLOR;
                    UNITY_VERTEX_OUTPUT_STEREO
                };

                sampler2D _MainTex;
                sampler2D _GradMap;
                float4 _MainTex_ST;
                half _GradPow;
                half _AmbientPow;
                half _Glow;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);

                    // Calculate the world normal, tangent, and binormal
                    float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                    float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                    half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                    float3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
                    // Construct a world to tangent rotation matrix
                    float3x3 worldToTangent = float3x3(worldTangent, worldBinormal, worldNormal);

                    // Rotate world space light direction
                    float3 tangentLightDir = mul(worldToTangent, _WorldSpaceLightPos0.xyz);

                    // Apply UV space rotation
                    float2 lightVec = normalize(tangentLightDir.xy);
                    float2x2 lightVecRotationMatrix = float2x2(lightVec.x, -lightVec.y, lightVec.y, lightVec.x);
                    o.uv.zw = mul(mul(o.uv.xy - 0.5, lightVecRotationMatrix),float2x2(0,1,-1,0)) + 0.5;

                    o.color = v.color * float4(_LightColor0.rgb,1) * _Glow;
                    o.color.rgb += ShadeSH9(half4(worldNormal,1)) * _AmbientPow;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 col = tex2D(_MainTex, i.uv.xy);
                    fixed4 col2 = tex2D(_GradMap, i.uv.zw);
                    col2.rgb = 1 + (saturate(i.color.a * 1.6) * _GradPow * (col2.rgb - 1)); //This line can be removed if you have no intention to animate gradient power, but the gradient should fade sooner as opacity drops because of reduced thickness.
                    col *= col2 * i.color;
                    return col;
                }
                ENDCG
            }
        }
        Fallback "Diffuse"
}
