Shader "Custom/hairSelf" 
{
	Properties
	{
		_MainTex("Albedo Texture", 2D) = "white" {}
		_AlphaTex("Alpha Texture", 2D) = "white" {}
		_Brightness("Brightness", 2D) = "white" {}

		_Cutoff("alpha cutoff",Range(0,1)) = 0.5
		_SpecularShift("Specular Shift", 2D) = "gray" {}
		_MaterialColor("MaterialColor",Color) = (1,1,1,1)
		_TintColor("Tint Color", Color) = (1,1,1,1)
		_Highlight1("Primary Highlight", Color) = (1,1,1,1)
		_Highlight2("Secondary Highlight", Color) = (1,1,1,1)
		_SecondarySparkle("Secondary Highlight Sparkle", 2D) = "white" {}

		// These values are from the Blacksmith hair shader (Unity Asset Store)
		_PrimaryShift("Primary Shift", Range(-5.0, 5.0)) = 0.275
		_SecondaryShift("Secondary Shift", Range(-5.0, 5.0)) = -0.040
		_SpecExp1("Specularity Exponent 1", Float) = 64
		_SpecExp2("Specularity Exponent 2", Float) = 48

		_Ambient("Ambient Lighting", Range(0, 1)) = 0.7
		_AmbientColor("Ambient Color", Color) = (1,1,1,1)

		_OpacityOn("Activate Deep Opacity Map", Range(0, 1)) = 1
		_OpacityRGB("Display Deep Opacity Map Layers", Range(0, 1)) = 0
		_OpacityGreyscale("Display Deep Opacity Map Values", Range(0, 1)) = 0
	}

	SubShader
	{
	Pass
	{
		Tags{ "LightingType" = "ForwardBase" }
		LOD 2000
		ZWrite on
		//Cull Back
			Cull Off
		CGPROGRAM
#include "Lighting.cginc"
#include "AutoLight.cginc"
#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

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
		SHADOW_COORDS(5) // put shadows data into TEXCOORD1
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
		o.viewDir = normalize(o.worldPos - _WorldSpaceCameraPos);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);

		//o.worldTangent = UnityObjectToWorldDir(v.tangent);
		//half tangentSign = v.tangent.w*unity_WorldTransformParams.w;
		//o.worldBiTangent = cross(o.worldNormal, o.worldTangent) * tangentSign;

		o.worldBiTangent = UnityObjectToWorldDir(v.tangent);
		o.worldTangent = cross(o.worldBiTangent,o.worldNormal);
		TRANSFER_SHADOW(o)
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
		half3 spec1 = StrandSpecular(t1, i.viewDir, worldLightDir, _Exponent) * _MaterialColor;
		half3 spec2 = StrandSpecular(t2, i.viewDir, worldLightDir, _Exponent2) * _MaterialColor;



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
	fixed3 color = (ambient * _MaterialColor.rgb + diffuse * _MaterialColor.rgb) * tex.rgb + spec1 + spec2;
	fixed shadow = SHADOW_ATTENUATION(i);
	return fixed4(color, 1.0) * shadow;

	}
		ENDCG
	}

		Pass
		{
			Tags {"Queue" = "Transparent" "RenderType" = "Transparent" }
			LOD 100
			ZWrite Off
			Cull Off
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 
#include "UnityCG.cginc" 
#include "Lighting.cginc" 
#include "AutoLight.cginc"
			int numberOfSetBits(int i)
			{
				int count = 0;
				i = max(0, i);
				while (i)
				{
					count += i & 1;
					i >>= 1;
				}
				return count;
			}
	uint mask(int n, int num_rightmost_bits)
	{
		int result = n;
		num_rightmost_bits = min(16, num_rightmost_bits);
		int mask = 0;
		for (int i = 0; i < num_rightmost_bits; i++)
		{
			mask |= 1 << i;
		}
		result &= mask;
		return result;
	}
	float Normalize_Depth(float z, float near, float far)
	{
		return (z - near) / (far - near);
	}
	float Get_True_Depth(float z, float near, float far)
	{
		return z * (far - near) + near;
	}
	float3 ShiftTangent(float3 T, float3 N, float shift)
	{
		float3 shiftedT = T + shift * N;
		return normalize(shiftedT);
	}
	float StrandSpecular(float3 T, float3 V, float3 L, float exponent)
	{
		float3 H = normalize(L + V);
		float dotTH = dot(T, H);
		float sinTH = sqrt(1.0 - dotTH * dotTH);
		float dirAtten = smoothstep(-1.0, 0.0, dot(T, H));
		return  dirAtten * pow(sinTH, exponent);
	}
	float4 HairLighting(float3 tangent, float3 normal, float3 lightVec, float3 viewVec, float2 uv,
		float specShift, float primaryShift, float secondaryShift, float3 diffuseAlbedo, float3 tint, float3 specularColor1,
		float specExp1, float3 specularColor2, float specExp2, float secondarySparkle, float3 lightColor, float3 ambientColor)
	{
		tangent *= -1;
		float shiftTex = specShift;// tex2D(tSpecShift, uv) ?.5; 
		float3 t1 = ShiftTangent(tangent, normal, primaryShift + shiftTex);
		float3 t2 = ShiftTangent(tangent, normal, secondaryShift + shiftTex);
		float3 diffuse = saturate(lerp(0.25, 1.0, dot(normal, lightVec) + ambientColor));
		diffuse *= diffuseAlbedo * tint;
		float3 specular = specularColor1 * StrandSpecular(t1, viewVec, lightVec, specExp1);
		float specMask = secondarySparkle; // approximate sparkles using texture
		float4 o;
		o.rgb = (diffuse + specular) * diffuseAlbedo * lightColor;
		o.a = 1;
		return o;
	}
	sampler2D _MainTex;
	sampler2D _AlphaTex;
	sampler2D _Brightness;
	sampler2D _SpecularShift;
	sampler2D _Test;
	float4 _MainTex_ST;
	float4 _TintColor;
	float4 _Highlight1;
	float4 _Highlight2;
	float _PrimaryShift;
	float _SecondaryShift;
	sampler2D _SecondarySparkle;
	float _SpecExp1;
	float _SpecExp2;
	float _Ambient;
	float4 _AmbientColor;
	float _OpacityOn;
	float _OpacityRGB;
	float _OpacityGreyscale;
	sampler2D _DeepOpacityMap;
	sampler2D _HeadDepth;
	float4x4 _DepthView;
	float4x4 _DepthVP;
	float4 _DepthScreenParams;
	float4 _DepthZBufferParams;
	float4 _DepthCameraPlanes;
	float _Layer1Thickness;
	float _Layer2Thickness;
	float _Layer3Thickness;
	float _CutoutThresh;
	float _AlphaMultiplier;
	sampler2D _MainDepth;
	sampler2D _MainOccupancy;
	sampler2D _MainSlab;
	sampler2D _HeadMainDepth;
	struct vertexInput {
		float4 pos : POSITION;
		float2 uv : TEXCOORD0;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
	};
	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD1;
		float3 tangentWorldSpace : TEXCOORD2;
		float3 normalWorldSpace : TEXCOORD3;
		float3 biTangentWorldSpace : TEXCOORD4;
		float4 posModelSpace : TEXCOORD5;
		float4 deepOpacity : TEXCOORD6;
		float4 scrPos : TEXCOORD7;
		float3 viewPos : TEXCOORD8;
	};
	v2f vert(vertexInput v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.pos);
		o.viewPos = UnityObjectToViewPos(v.pos);
		o.posModelSpace = v.pos;
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		o.tangentWorldSpace = UnityObjectToWorldNormal(v.tangent);
		o.normalWorldSpace = UnityObjectToWorldNormal(v.normal);
		o.biTangentWorldSpace = normalize(cross(o.normalWorldSpace,o.tangentWorldSpace)) * v.tangent.w;
		o.scrPos = ComputeScreenPos(o.pos);
		return o;
	}
	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col;
		i.scrPos /= i.scrPos.w;
		float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
		float3 viewDirection = normalize(WorldSpaceViewDir(i.posModelSpace));
		col.rgb = HairLighting(i.biTangentWorldSpace, i.normalWorldSpace, lightDirection, viewDirection,
			i.uv,
			tex2D(_SpecularShift, i.uv).r - 0.5, _PrimaryShift, _SecondaryShift, tex2D(_MainTex, i.uv).rgb, _TintColor,
			_Highlight1, _SpecExp1, _Highlight2, _SpecExp2, tex2D(_SecondarySparkle, i.uv).r, _LightColor0,
			_Ambient * _AmbientColor);
		col.a = 1;
		return col;
	}
		ENDCG
		}
	}
}