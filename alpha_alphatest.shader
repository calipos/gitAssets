Shader "Custom/alpha_alphatest"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
		_Cutoff("alpha cutoff",Range(0,1))=0.5
    }
    SubShader
    {
        Tags { "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
        LOD 200
		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"
		struct appdata
		{
			float4 vertex:POSITION;
			float3 normal:NORMAL;
			float2 uv:TEXCOORD0;
		};
		struct v2f
		{
			float4 pos:SV_POSITION;
			float2 uv:TEXCOORD0;
			float3 worldNormal:TEXCOORD1;
			float3 worldPos:TEXCOORD2;
		};
		sampler2D _MainTex;
		float4 _MainTex_ST;
		fixed4 _Color;
		fixed _Cutoff;
		v2f vert(appdata i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			o.uv = TRANSFORM_TEX(i.uv,_MainTex);
			o.worldNormal = UnityObjectToWorldNormal(i.normal);
			o.worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
			return o;
		}
		fixed4 frag(v2f i):SV_TARGET
		{
			fixed3 worldNormal = i.worldNormal;
			fixed3 worldPos = i.worldPos;
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
			fixed4 texColor = tex2D(_MainTex, i.uv);
			clip(texColor.a - _Cutoff);
			fixed3 albedo = texColor.rgb * _Color.rgb;
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
			fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
			return fixed4(ambient + diffuse, 1.0);
		}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
