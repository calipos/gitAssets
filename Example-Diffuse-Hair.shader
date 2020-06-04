Shader "Custom/Example-Diffuse-Hair"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
	_Cutoff("Cutoff", Range(0,1)) = 0.5
	}

		SubShader
	{
		Tags
	{
		"RenderType" = "Transparent"
		"IgnoreProjector" = "True"
		"Queue" = "Transparent+100"
	}
		LOD 200

		Pass
	{
		Tags
	{
		"LightMode" = "ForwardBase"
	}
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fwdbase

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"

		fixed4 _Color;
	sampler2D _MainTex;
	float _Cutoff;

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float3 normal : NORMAL;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float3 worldPos : TEXCOORD1;
		float3 worldNormal : TEXCOORD2;
	};

	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		o.worldPos = mul(unity_ObjectToWorld, v.vertex);
		o.worldNormal = UnityObjectToWorldNormal(v.normal);
		return o;
	}

	fixed4 frag(v2f i) : SV_TARGET
	{
		fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
	clip(albedo.a - _Cutoff);

	fixed3 ambient = albedo.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb;

	fixed3 worldLight = UnityWorldSpaceLightDir(i.worldPos);
	float d = dot(worldLight, i.worldNormal) * 0.5 + 0.5;
	fixed3 diffuse = albedo.rgb * _LightColor0.rgb * d;

	fixed4 col = fixed4(ambient + diffuse * 2, albedo.a);

	return col;
	}

		ENDCG
	}

		Pass
	{
		Tags
	{
		"LightMode" = "ForwardBase"
	}
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fwdbase

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"

		fixed4 _Color;
	sampler2D _MainTex;
	float _Cutoff;

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float3 normal : NORMAL;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float3 worldPos : TEXCOORD1;
		float3 worldNormal : TEXCOORD2;
	};

	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		o.worldPos = mul(unity_ObjectToWorld, v.vertex);
		o.worldNormal = UnityObjectToWorldNormal(v.normal);
		return o;
	}

	fixed4 frag(v2f i) : SV_TARGET
	{
		fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
	clip(_Cutoff - albedo.a);

	fixed3 ambient = albedo.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb;

	fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
	float d = dot(worldLight, i.worldNormal) * 0.5 + 0.5;
	fixed3 diffuse = albedo.rgb * _LightColor0.rgb * d;

	fixed4 col = fixed4(ambient + diffuse * 2, albedo.a);

	return col;
	}

		ENDCG
	}


	}

		Fallback "Diffuse"
}