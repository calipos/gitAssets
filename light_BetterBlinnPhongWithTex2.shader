Shader "Custom/light_BetterBlinnPhongWithTex2"
{
	Properties
	{
		_MaterialColor("MaterialColor",Color) = (1,1,1,1)
		_SpecularStrength("Specular",Range(0.0,5.0)) = 1.0
		_Gloss("Gloss",Range(1.0,255)) = 20
		_MainTex("Main Texture",2D) = "white"{}
		_Cutoff("alpha cutoff",Range(0,1)) = 0.5

		_BumpMap("Bump Map", 2D) = "bump"{}
		_HeightMap("Height Map", 2D) = "black"{}
		_HeightFactor("Height Scale", Range(0, 0.1)) = 0.05

		_ShiftMap("_Shift Map", 2D) = "black"{}
		_PrimaryShift("PrimaryShift", Range(-1, 1)) = 0.
		_SecondaryShift("SecondaryShift", Range(-1, 1)) = 0.
		_Exponent("Exponent", Range(4, 32)) = 16
		_Exponent2("Exponent2", Range(4, 32)) = 16
	}
		SubShader{
		Pass{
		Tags{ "LightingType" = "ForwardBase" }
		LOD 200
		CGPROGRAM
#include "Lighting.cginc"
#pragma vertex vert
#pragma fragment frag

		fixed4 _MaterialColor;
	float _SpecularStrength;
	float _Gloss;
	sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed _Cutoff;

	sampler2D _BumpMap;
	float _HeightFactor;
	sampler2D _HeightMap;

	sampler2D _ShiftMap;
	fixed _PrimaryShift;
	fixed _SecondaryShift;
	fixed _Exponent;
	fixed _Exponent2;

	struct appdata {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 uv : TEXCOORD0;
		float4 tangent:TANGENT;
	};

	struct v2f {
		float4 pos : SV_POSITION;
		float3 worldNormal : NORMAL;
		float3 viewDir : TEXCOORD0;
		float2 uv : TECOORD1;		
		float3 worldPos : TEXCOORD2;
		float3 worldTangent:TEXCOORD3;
		float3 worldBiTangent:TEXCOORD4;
	};
	//计算uv偏移值
	inline float2 CaculateParallaxUV(v2f i)
	{
		float height = tex2D(_HeightMap, i.uv).r;
		float3 viewDir = normalize(i.viewDir);
		float2 offset = viewDir.xy / viewDir.z * height * _HeightFactor;
		return offset;
	}
	inline fixed3 ShiftTangent(float3 T, float3 N, float shift)
	{
		return normalize(T + shift * N);
	}
	fixed StrandSpecular(fixed3 T, fixed3 V, fixed3 L, fixed exponent)
	{
		fixed3 H = normalize(L + V);
		fixed dotTH = dot(T, H);
		fixed sinTH = sqrt(1 - dotTH * dotTH);
		fixed dirAtten = smoothstep(-1, 0, dotTH);
		return dirAtten * pow(sinTH, exponent);
	}

	v2f vert(appdata v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.worldNormal = UnityObjectToWorldNormal(v.normal);
		o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		o.viewDir = normalize(o.worldPos-_WorldSpaceCameraPos );
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);

		o.worldTangent = UnityObjectToWorldDir(v.tangent);
		half tangentSign = v.tangent.w*unity_WorldTransformParams.w;
		o.worldBiTangent = cross(o.worldNormal, o.worldTangent) * tangentSign;
		return o;
	}
	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 tex = tex2D(_MainTex, i.uv);
		clip(tex.a - _Cutoff);

		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
		fixed3 worldNormal = normalize(i.worldNormal);
		fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

		fixed shiftValue = tex2D(_ShiftMap, i.uv).r;
		half3 t1 = ShiftTangent(i.worldBiTangent, i.worldNormal, _PrimaryShift + shiftValue);
		half3 t2 = ShiftTangent(i.worldBiTangent, i.worldNormal, _SecondaryShift + shiftValue);
		half3 spec1 = StrandSpecular(t1, i.viewDir, worldLightDir, _Exponent)* _MaterialColor;
		half3 spec2 = StrandSpecular(t2, i.viewDir, worldLightDir, _Exponent2)* _MaterialColor;


	
	float2 uvOffset = CaculateParallaxUV(i);
	i.uv += uvOffset;
	float3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv)); 	
	fixed3 lambert = saturate(dot(tangentNormal, worldLightDir));
	//fixed lambert = max(0, dot(worldNormal, worldLightDir));

	fixed3 diffuse = lambert * _LightColor0.xyz;

	//fixed3 viewDir = normalize(i.viewDir);
	//fixed3 halfDir = normalize(worldLightDir + viewDir);
	//fixed3 specular = _LightColor0.rgb *_SpecularStrength * pow(max(0.0, dot(halfDir, worldNormal)), _Gloss);	
	//fixed3 color = (ambient * _MaterialColor.rgb + diffuse * _MaterialColor.rgb + specular * _MaterialColor.rgb * tex.a) * tex.rgb;
	
	//fixed3 color = (ambient * _MaterialColor.rgb + diffuse * _MaterialColor.rgb + spec1 * tex.a + spec2 * tex.a) * tex.rgb;
	fixed3 color = (ambient * _MaterialColor.rgb + diffuse * _MaterialColor.rgb ) * tex.rgb + spec1  + spec2 ;

	return fixed4(color, 1.0);

	}
		ENDCG
	}
	}
		FallBack "Diffuse"
}
