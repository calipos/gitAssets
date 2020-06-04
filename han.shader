﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/*
*Hi, I'm Lin Dong,
*this shader is about human skin's real time rendering in unity3d
*add some water drop effect that is dynamic state
*looks like the model perspiration or take a bath
*you can ctrl the color of the water, and the drop speed, drop direction etc.
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/han" {
	Properties{
	_SpeedStrength("Speed (XY), Strength (ZW)", Vector) = (1, 1, 1, 1)
	_RefractTexTiling("Refraction Tilefac", Range(0.1, 6)) = 1
	_RefractTex("Refraction (RG), Colormask (B)", 2D) = "white" {}
	_Color("Color (RGB)", Color) = (1, 1, 1, 1)
		_WaterColor("Water Color (RGBA)", Color) = (1, 1, 1, 1)
		_NonTex("DON`T TOUCH IT! :)", RECT) = "white" {}
	_WaterNormalTex("WaterNormalTex", 2D) = "white" {}
	_WaterGL("gloss", Range(0, 1)) = 0.5
		_WaterReflAmount("WaterReflAmount", Range(0, 1)) = 0.5

		_MainTex("Base (RGB)", 2D) = "white" {}
	_SpecularTex("Specular (RGB)", 2D) = "white" {}
	_SpecularPower("Specular Power", Range(0.04, 1)) = 1

		_AlbedoTex("Albedo (RGB)", 2D) = "white" {}
	_AlbedoPower("Albedo Power", Range(0, 20)) = 1
		_AlbedoDistance("Albedo Distance", Range(0.1, 2)) = 1

		_BRDFTex("BRDF (RGB)", 2D) = "white" {}
	_CurveScale("Curvature Scale", Range(0.001, 0.09)) = 0.01

		_BlurTex1("Blur Tex 1 (RGB)", 2D) = "white" {}
	_BlurTex2("Blur Tex 2 (RGB)", 2D) = "white" {}
	_BlurTex3("Blur Tex 3 (RGB)", 2D) = "white" {}
	_BlurTex4("Blur Tex 4 (RGB)", 2D) = "white" {}
	_BlurTex5("Blur Tex 5 (RGB)", 2D) = "white" {}
	_BlurTex6("Blur Tex 6 (RGB)", 2D) = "white" {}

	_DetailTex("Detail (RGB)", 2D) = "white" {}
	_BumpBias("Normal Map Blur", Range(0, 5)) = 2.0
		_Maintint("Main Color", Color) = (1, 1, 1, 1)
		_Cubemap("CubeMap", CUBE) = ""{}
	_SC("Specular Color", Color) = (1, 1, 1, 1)
		_GL("gloss", Range(0, 0.1)) = 0.05
		_nMips("nMipsF", Range(0, 5)) = 0.5
		_ReflAmount("Reflection Amount", Range(0.01, 1)) = 0.5


		_RimPower("RimPower", Range(0.1, 0.8)) = 0.5
		_RimColor("Rim Color", Color) = (1, 1, 1, 1)

		_FrontRimPower("Front RimPower", Range(0.1, 0.8)) = 0.5
		_FrontRimColor("Front Rim Color", Color) = (1, 1, 1, 1)
		_FrontRimTex("Front Rim (RGB)", 2D) = "white" {}

}
	SubShader{
		pass{
		Tags{ "LightMode" = "ForwardBase" }
		ZWrite on
			Cull Back

			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "AutoLight.cginc"
			sampler2D _NonTex;
		sampler2D _RefractTex;
		float4 _SpeedStrength;
		float4 _WaterColor;
		float _RefractTexTiling;
		float4 _Color;
		sampler2D _WaterNormalTex;
		float _WaterGL;
		float _WaterReflAmount;

		float4x4  _World2Light;
		float4 _LightColor0;
		samplerCUBE _Cubemap;
		float _SpecularPower;
		float4 _SC;
		float _GL;
		float4 _Maintint;
		float _nMips;
		float _ReflAmount;

		sampler2D _AlbedoTex;
		float _AlbedoPower;
		float _AlbedoDistance;

		sampler2D _BRDFTex;
		float _CurveScale;

		float _RimPower;
		float4 _RimColor;

		float _FrontRimPower;
		float4 _FrontRimColor;
		sampler2D _FrontRimTex;

		sampler2D _BlurTex1;
		sampler2D _BlurTex2;
		sampler2D _BlurTex3;
		sampler2D _BlurTex4;
		sampler2D _BlurTex5;
		sampler2D _BlurTex6;

		sampler2D _SpecularTex;
		sampler2D _MainTex;
		sampler2D _DetailTex;
		float4 _MainTex_ST;
		float4 _DetailTex_ST;
		float _BumpBias;
		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv_MainTex : TEXCOORD0;
			float3 lightDir : TEXCOORD1;
			float3 viewDir : TEXCOORD2;
			float3 normal : TEXCOORD3;
			float4 worldpos : TEXCOORD4;
			float2 uv_DetailTex : TEXCOORD5;
		};
		struct appdata {
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
			fixed4 color : COLOR;
		};
		v2f vert(appdata_full v) {
			v2f o;
			o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.uv_DetailTex = TRANSFORM_TEX(v.texcoord, _DetailTex);

			o.pos = UnityObjectToClipPos(v.vertex);

			o.worldpos = mul(unity_ObjectToWorld, v.vertex);
			o.normal = v.normal;
			o.lightDir = ObjSpaceLightDir(v.vertex);
			o.viewDir = ObjSpaceViewDir(v.vertex);


			return o;
		}
#define PIE 3.1415926535	


		float4 frag(v2f i) :COLOR
		{
			float3 viewDir = normalize(i.viewDir);
			float3 lightDir = normalize(i.lightDir);
			float3 H = normalize(lightDir + viewDir);
			/*
			*this part is about blend normal, normal map and detail map
			*and the nomal blur also in here
			*this blend method is from internet
			*/
			float3 n1 = tex2Dbias(_DetailTex, float4(i.uv_MainTex, 0.0, _BumpBias)) * 2 - 1;//normalBlur
			float3 n2 = normalize(i.normal) * 2 - 1;

			float a = 1 / (1 + n1.z);
			float b = -n1.x*n1.y*a;

			float3 b1 = float3(1 - n1.x*n1.x*a, b, -n1.x);
			float3 b2 = float3(b, 1 - n1.y*n1.y*a, -n1.y);
			float3 b3 = n1;

			if (n1.z < -0.9999999)
			{
				b1 = float3(0, -1, 0);
				b2 = float3(-1, 0, 0);
			}

			float3 r = n2.x*b1 + n2.y*b2 + n2.z*b3;

			n2 = r*0.5 + 0.5;

			n2 *= 3;
			n2 += n1;
			n2 /= 4;
			n2 = normalize(n2);

			/*
			*this part is compute Physically-Based Rendering
			*the method is in the ppt about "ops2"
			*/

			float _SP = pow(8192, _GL);
			float d = (_SP + 2) / (8 * PIE) * pow(dot(n2, H), _SP);
			float f = _SC + (1 - _SC)*pow(2, -10 * dot(H, lightDir));
			float k = min(1, _GL + 0.545);
			float v = 1 / (k* dot(viewDir, H)*dot(viewDir, H) + (1 - k));

			float all = d*f*v;
			float3 refDir = reflect(-viewDir, n2);
			float3 ref = texCUBElod(_Cubemap, float4(refDir, _nMips - _GL*_nMips)).rgb;

			float3 c = tex2D(_MainTex, i.uv_MainTex) * 128;
			c += tex2D(_BlurTex1, i.uv_MainTex) * 64;
			c += tex2D(_BlurTex2, i.uv_MainTex) * 32;
			c += tex2D(_BlurTex3, i.uv_MainTex) * 16;
			c += tex2D(_BlurTex4, i.uv_MainTex) * 8;
			c += tex2D(_BlurTex5, i.uv_MainTex) * 4;
			c += tex2D(_BlurTex6, i.uv_MainTex) * 2;
			c /= 256;

			float3 diff = dot(lightDir, n2);
			all = saturate(all);;
			diff = (1 - all)*diff;
			diff = saturate(diff);
			/*
			*this part is supplement the specular
			*to add the oil's feel
			*/
			float specBase = max(0, dot(n2, H));
			float spec = pow(specBase, 10) *(_GL + 0.2);
			spec = lerp(0, 1.2, spec);
			float3 spec3 = spec * (tex2D(_SpecularTex, i.uv_MainTex) - 0.1);
			spec3 *= Luminance(diff);
			spec3 = saturate(spec3);
			spec3 *= _SpecularPower;

			/*
			*this part is to add the sss
			*used front rim,back rim and BRDF
			*/

			float3 rim = (1 - dot(viewDir, n2))*_RimPower * _RimColor;
			float3 frontrim = (dot(viewDir, n2))*_FrontRimPower * _FrontRimColor *tex2D(_FrontRimTex, i.uv_MainTex);

			fixed atten = LIGHT_ATTENUATION(i);
			float curvature = length(fwidth(mul(unity_ObjectToWorld, float4(normalize(i.normal), 0)))) /
				length(fwidth(i.worldpos)) * _CurveScale;

			float3 brdf = tex2D(_BRDFTex, float2((dot(normalize(i.normal), lightDir) * 0.5 + 0.5)* atten, curvature)).rgb;

			float4 c2 = float4(lerp(c, ref, _ReflAmount) *(diff*_Maintint + (all*_SC) / 2)*brdf + rim + frontrim + spec3 + (all*_SC) / 2, 1);
			if (_WorldSpaceLightPos0.w != 0)
			{
				float dis = distance(_WorldSpaceLightPos0, i.worldpos);
				dis *= _AlbedoDistance;
				if (1 - dis > 0)
					c2 += tex2D(_AlbedoTex, float2(0.5, 1 - dis))*_AlbedoPower;
			}

			/*
			*this part add the water drop effect
			*the method is in the unity wiki
			* I add some PBR things make the water drop more sparkling and more stereoscopic,looks realistic
			*/
			float2 refrtc = i.uv_MainTex*_RefractTexTiling;//_RefractTexTiling is scale for uv
			float4 refract = tex2D(_RefractTex, refrtc + _SpeedStrength.xy*_Time.x);
			if (refract.a > 0.3)
			{
				refract.rg = refract.rg*2.0 - 1.0;

				float4 original = tex2D(_NonTex, i.uv_MainTex + refract.rg*_SpeedStrength.zw);

				n2 = UnpackNormal(tex2D(_WaterNormalTex, refrtc + _SpeedStrength.xy*_Time.x));
				_SP = pow(8192, _WaterGL);
				d = (_SP + 2) / (8 * PIE) * pow(dot(n2, H), _SP);
				f = _SC + (1 - _SC)*pow(2, -10 * dot(H, lightDir));
				k = min(1, _WaterGL + 0.545);
				v = 1 / (k* dot(viewDir, H)*dot(viewDir, H) + (1 - k));

				all = d*f*v;
				float3 refDir = reflect(-viewDir, n2);
				float3 ref = texCUBElod(_Cubemap, float4(refDir, _nMips - _WaterGL*_nMips)).rgb;

				original = lerp(original, float4(ref, 1), _WaterReflAmount);

				float4 output = lerp(original, original*_Color, refract.b);
				output.a = original.a;
				c2 += (output + all*_WaterColor / 4)* _WaterColor.a*dot(lightDir, n2);
			}

			c2 *= atten;
			return c2;
		}
		ENDCG
	}
	}
}
