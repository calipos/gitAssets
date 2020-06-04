// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/12_reflect_withNromalMap"
{
    Properties
    {
		_BumpMap("Normal Map",2D) = "bump"{}
    }
    SubShader
    {
		Pass
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 3.0
#include "UnityCG.cginc"
		struct appdata
		{
			float4 vertex:POSITION;
			float3 normal:NORMAL;
			float4 tangent:TANGENT;
			float2 uv:TEXCOORD0;
		};
	struct v2f
	{
		float3 worldPos:TEXCOORD0;
		half3 tspace0:TEXCOORD1;
		half3 tspace1:TEXCOORD2;
		half3 tspace2:TEXCOORD3;
		float2 uv:TEXCOORD4;
		float4 pos:SV_POSITION;
	};
	v2f vert(appdata i)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(i.vertex);
		o.worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
		half3 wNormal = UnityObjectToWorldNormal(i.normal);
		half3 wTangent = UnityObjectToWorldDir(i.tangent);
		half tangentSign = i.tangent.w*unity_WorldTransformParams.w;
		half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
		o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
		o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
		o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
		o.uv = i.uv;
		return o;
	}


	sampler2D _BumpMap;

	fixed4 frag(v2f i) : SV_Target
	{
		// sample the normal map, and decode from the Unity encoding
		half3 tnormal = UnpackNormal(tex2D(_BumpMap, i.uv));
		// transform normal from tangent to world space
		half3 worldNormal;
		worldNormal.x = dot(i.tspace0, tnormal);
		worldNormal.y = dot(i.tspace1, tnormal);
		worldNormal.z = dot(i.tspace2, tnormal);

		// rest the same as in previous shader
		half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
		half3 worldRefl = reflect(-worldViewDir, worldNormal);
		half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl);
		half3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);
		fixed4 c = 0;
		c.rgb = skyColor;
		return c;
	}
		ENDCG
	}
        
    }
    FallBack "Diffuse"
}
