﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/11_reflict"
{
    Properties
    {
    }
    SubShader
    {
		Pass
		{
		Tags { "RenderType" = "Opaque" }
		LOD 200
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 3.0
#include "UnityCG.cginc"
		struct v2f
		{
			half3 worldRefl:TEXCOORD0;
			float4 pos:SV_POSITION;
		};
	v2f vert(float4 vertex :POSITION,float3 normal:NORMAL) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(vertex);
		float3 worldPos = mul(unity_ObjectToWorld, vertex).xyz;
		float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
		float3 worldNormal = UnityObjectToWorldNormal(normal);
		o.worldRefl = reflect(-worldViewDir, worldNormal);
		return o;
	}
	fixed4 frag(v2f i):SV_TARGET
	{
		half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.worldRefl);
		half3 skyColor = DecodeHDR(skyData,unity_SpecCube0_HDR);
		fixed4 c = 0;
		c.rgb = skyColor;
		return c;
	}
		ENDCG
		}
    }
    FallBack "Diffuse"
}