﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Custom/hairbasic"
{
	Properties
	{
		_MainTex("Albedo Texture", 2D) = "white" {}
		_AlphaTex("Alpha Texture", 2D) = "white" {}
		_Brightness("Brightness", 2D) = "white" {}

		_SpecularShift("Specular Shift", 2D) = "gray" {}

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
			Tags {"Queue" = "Transparent" "RenderType" = "Transparent" }
			//Tags {"RenderType" = "Opaque" }
			LOD 100
			//Transparent
			//ZWrite On
			ZWrite Off
			//AlphaTest GEqual [_CutoutThresh]
			//Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			Blend One One


			Pass
			{
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

	//return 1;
	//// Java: use >>> instead of >>
	//// C or C++: use uint32_t
	//i = i - ((i >> 1) & 0x55555555);
	//i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
	//return (((i + (i >> 4)) & 0x0F0F0F0F) * 0x01010101) >> 24;
}

				// Sets all upper bits of input to 0
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

				// Convert from normalized to original depth
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
					return dirAtten * pow(sinTH, exponent);
				}

				float4 HairLighting(float3 tangent, float3 normal, float3 lightVec, float3 viewVec, float2 uv,
					float specShift, float primaryShift, float secondaryShift, float3 diffuseAlbedo, float3 tint, float3 specularColor1,
					float specExp1, float3 specularColor2, float specExp2, float secondarySparkle, float3 lightColor, float3 ambientColor)
				{
					tangent *= -1;
					// shift tangents
					float shiftTex = specShift;// tex2D(tSpecShift, uv) ?.5; 
					float3 t1 = ShiftTangent(tangent, normal, primaryShift + shiftTex);
					float3 t2 = ShiftTangent(tangent, normal, secondaryShift + shiftTex);
					// diffuse lighting: the lerp shifts the shadow boundary for a softer look
					float3 diffuse = saturate(lerp(0.25, 1.0, dot(normal, lightVec) + ambientColor));
					//float3 diffuse = saturate(lerp(0.25, 1.0, dot(normal, lightVec)));
					diffuse *= diffuseAlbedo * tint;

					// specular lighting
					float3 specular = specularColor1 * StrandSpecular(t1, viewVec, lightVec, specExp1);
					// add 2nd specular term, modulated with noise texture
					float specMask = secondarySparkle; // approximate sparkles using texture
					specular += specularColor2 * specMask * StrandSpecular(t2, viewVec, lightVec, specExp2);
					// final color assembly
					float4 o;
					o.rgb = (diffuse + specular) * diffuseAlbedo * lightColor;
					// alpha will be adjusted outside of this function
					o.a = 1;
					return o;

				}
 

				sampler2D _MainTex;
				sampler2D _AlphaTex;
				sampler2D _Brightness;

				sampler2D _SpecularShift;

				sampler2D _Test;
				// For offset and scaling; just here as an example.
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

				// Shader toggles
				float _OpacityOn;
				float _OpacityRGB;
				float _OpacityGreyscale;


				// generated by MeshSorter script
				sampler2D _DeepOpacityMap;
				sampler2D _HeadDepth;

				// generated by DeepOpacity script
				float4x4 _DepthView;
				//float4x4 _DepthProjection;
				float4x4 _DepthVP;
				float4 _DepthScreenParams;
				float4 _DepthZBufferParams;
				float4 _DepthCameraPlanes;

				float _Layer1Thickness;
				float _Layer2Thickness;
				float _Layer3Thickness;


				// generated by TransparencySorting script
				float _CutoutThresh;
				float _AlphaMultiplier;

				sampler2D _MainDepth;
				sampler2D _MainOccupancy;
				sampler2D _MainSlab;
				sampler2D _HeadMainDepth;


				/**
				  Input to vertex shader.
				*/
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

					o.biTangentWorldSpace = UnityObjectToWorldNormal(v.tangent);
					o.normalWorldSpace = UnityObjectToWorldNormal(v.normal);
					o.tangentWorldSpace = normalize(cross(o.biTangentWorldSpace,o.normalWorldSpace)) * v.tangent.w;

					// https://docs.unity3d.com/Manual/SL-DepthTextures.html
					// http://williamchyr.com/2013/11/unity-shaders-depth-and-normal-textures/
					o.scrPos = ComputeScreenPos(o.pos);

					return o;
				}


				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col;
					i.scrPos /= i.scrPos.w;
					// Get light direction in world space.
					// @TODO: add support for point lights (needs different approach)
					float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

					// Get view direction in world space.
					float3 viewDirection = normalize(WorldSpaceViewDir(i.posModelSpace));

					col.rgb = HairLighting(i.biTangentWorldSpace, i.normalWorldSpace, lightDirection, viewDirection,
						i.uv,
						tex2D(_SpecularShift, i.uv).r - 0.5, _PrimaryShift, _SecondaryShift, tex2D(_MainTex, i.uv).rgb, _TintColor,
						_Highlight1, _SpecExp1, _Highlight2, _SpecExp2, tex2D(_SecondarySparkle, i.uv).r, _LightColor0,
						_Ambient * _AmbientColor
					);
					col.a=1;
					return col;
					// http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/#rendering-the-shadow-map
					float4 shadowWorld = mul(unity_ObjectToWorld, float4(i.posModelSpace.xyz, 1.0));
					float4 shadowCoord = mul(_DepthVP, shadowWorld);

					float4 shadowLightSpace = mul(_DepthView, shadowWorld);


					float4 o = shadowCoord * 0.5f;
					//float4 screenParams = float4(256, 256, 1 + 1 / 256, 1 + 1 / 256);
					#if defined(UNITY_HALF_TEXEL_OFFSET)
					//o.xy = float2(o.x, o.y*_ProjectionParams.x) + o.w * _ScreenParams.zw;
					o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w * _DepthScreenParams.zw;
					#else
					o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w;
					#endif

					o.zw = shadowCoord.zw;

					// "Computes texture coordinate for doing a screenspace-mapped texture sample. Input is clip space position."
					shadowCoord = o;
					// https://www.ronja-tutorials.com/2019/01/20/screenspace-texture.html
					shadowCoord.xy /= shadowCoord.w;

					float4 lightDepth = tex2D(_DeepOpacityMap, shadowCoord);
					float  headOcclusion = tex2D(_HeadDepth, shadowCoord).r;

					float culledDepth = Get_True_Depth(lightDepth.r, _DepthCameraPlanes.x, _DepthCameraPlanes.y);
					headOcclusion = Get_True_Depth(headOcclusion.r, _DepthCameraPlanes.x, _DepthCameraPlanes.y);

					culledDepth = min(culledDepth, headOcclusion);

					float z = -shadowLightSpace.z;


					float opacity = 0;
					float3 opacity_rgb = float3(0,0,0);

					// Is the head in the way?
					//if (headOcclusion < z)
					//{
					//	opacity = 1;
					//	opacity_rgb.b = 1;
					//}
					// layer 1
					if (z - _Layer1Thickness < culledDepth)
					{
						opacity = lerp(0, lightDepth.g, (z - culledDepth) / _Layer1Thickness);
						opacity_rgb.r = lerp(0, lightDepth.g, (z - culledDepth) / _Layer1Thickness);
					}
					// layer 2
					else if (z - _Layer1Thickness - _Layer2Thickness < culledDepth)
					{
						opacity = lerp(lightDepth.g, lightDepth.b, (z - _Layer1Thickness - culledDepth) / _Layer2Thickness);
						//float prevMax = lerp(0, lightDepth.g, (z - culledDepth) / _Layer1Thickness);
						float prevMax = lightDepth.g;
						opacity_rgb.g = lerp(0, lightDepth.b, (z - _Layer1Thickness - culledDepth) / _Layer2Thickness);
						opacity_rgb.r = lerp(prevMax, 0, (z - _Layer1Thickness - culledDepth) / _Layer2Thickness);
					}
					// layer 3
					else
					{
						opacity = lerp(lightDepth.b, lightDepth.a,
							(z - _Layer1Thickness - _Layer2Thickness - culledDepth) / _Layer3Thickness);

						float prevMax = lightDepth.b;
						//float prevMax = lerp(0, lightDepth.b, (z - _Layer1Thickness - culledDepth) / _Layer2Thickness);
						opacity_rgb.b = lerp(0, lightDepth.a,
							(z - _Layer1Thickness - _Layer2Thickness - culledDepth) / _Layer3Thickness);
						opacity_rgb.g = lerp(prevMax, 0,
							(z - _Layer1Thickness - _Layer2Thickness - culledDepth) / _Layer3Thickness);
					}

					opacity = max(0, opacity);

					opacity_rgb = lerp(opacity, opacity_rgb, _OpacityRGB);
					opacity_rgb = lerp(opacity_rgb, opacity, _OpacityGreyscale);
					opacity = lerp(0, opacity, _OpacityOn);

					// convert ambient lighting to greyscale
					// https://answers.unity.com/questions/343243/unlit-greyscale-shader.html
					float greyscaleAmbient = dot(_Ambient * _AmbientColor, float3(0.3, 0.59, 0.11));
					// Limit opacity to the ambient minimum
					opacity = min(1 - greyscaleAmbient, opacity);


					float4 nearFar = tex2D(_MainDepth, i.scrPos);
					float4 slabs = tex2D(_MainSlab, i.scrPos);
					uint4 occupancy = tex2D(_MainOccupancy, i.scrPos);

					float4 headNearFar = tex2D(_HeadMainDepth, i.scrPos);

					float depthValue = Normalize_Depth(-i.viewPos.z, _ProjectionParams.y, _ProjectionParams.z);

					if (depthValue >= headNearFar.r) {
						discard;
					}

					// Get relative depth of fragment
					float relativeDepth = (depthValue - nearFar.r) / (nearFar.a - nearFar.r);

					// Get closest slab
					int slab = floor(relativeDepth * 4);

					float allPreviousFragments = 0;
					float fragmentsInSlab = 0;
					float allFragments = slabs.r + slabs.g + slabs.b + slabs.a;

					if (slab == 0)
					{
						fragmentsInSlab = slabs.r;
					}
					else if (slab == 1)
					{
						allPreviousFragments = slabs.r;
						fragmentsInSlab = slabs.g;
					}
					else if (slab == 2)
					{
						allPreviousFragments = slabs.r + slabs.g;
						fragmentsInSlab = slabs.b;
					}
					else
					{
						allPreviousFragments = slabs.r + slabs.g + slabs.b;
						fragmentsInSlab = slabs.a;
					}


					float previousSlabFragments = 0;

					// Get closest slice
					int slice = floor(relativeDepth * 64);

					// Figure out which color channel to put the data into
					int color = floor(slice / 16);
					// bit in color channel (should be between 0 and 15, inclusive);
					int relativeSlice;

					float setBits = 0;
					float previousSetBits = 0;
					if (color == 0)
					{
						relativeSlice = slice;
						setBits = numberOfSetBits(occupancy.r);
						previousSetBits = numberOfSetBits(mask(occupancy.r, max(0, relativeSlice - 1)));

					}
					else if (color == 1)
					{
						relativeSlice = slice - 16 * 1;
						setBits = numberOfSetBits(occupancy.g);
						previousSetBits = numberOfSetBits(mask(occupancy.g, max(0, relativeSlice - 1)));
					}
					else if (color == 2)
					{
						relativeSlice = slice - 16 * 2;
						setBits = numberOfSetBits(occupancy.b);
						previousSetBits = numberOfSetBits(mask(occupancy.b, max(0, relativeSlice - 1)));
					}
					else
					{
						relativeSlice = slice - 16 * 3;
						setBits = numberOfSetBits(occupancy.a);
						previousSetBits = numberOfSetBits(mask(occupancy.a, max(0, relativeSlice - 1)));
					}

					//@TODO: Get working with occupancy map
					float s = slab;
					float inside = relativeDepth - s / 4;
					float previousFragments = 1 * (allPreviousFragments + (fragmentsInSlab * inside));// +((fragmentsInSlab / setBits) * previousSetBits);
					//float maxFragments = previousFragments +(fragmentsInSlab / setBits);
					//float interpolation = inside;

					//float depthOrder = lerp(previousFragments, maxFragments, interpolation);
					float depthOrder = previousFragments;
					//depthOrder = floor(depthOrder);
					//depthOrder = relativeDepth/1.5;
					//depthOrder = pow(2* depthOrder, 2);
					depthOrder = max(0, depthOrder);

					// formula from "Hair Self Shadowing and Transparency Depth Ordering Using Occupancy maps"
					float4 colorIn = float4(0, 0, 0, 1);
					colorIn.rgb = col.rgb * (1 - opacity);

					float4 colorOut = pow(1 - _AlphaMultiplier, depthOrder) * _AlphaMultiplier * colorIn;

					col.rgb = lerp(colorOut, opacity_rgb, max(_OpacityRGB, _OpacityGreyscale));
					col.a = colorOut.a;

					float alpha = tex2D(_AlphaTex, i.uv).r * _AlphaMultiplier;

					// Alpha cutoff.
					if (alpha < _CutoutThresh) {
						discard;
					}
					return col;
				}

			ENDCG
			}
		}
}