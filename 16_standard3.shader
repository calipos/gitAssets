Shader "Custom/16_standard2"
{
	Properties
	{ _Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}
	//Alpha剔除值
	_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
		//平滑、光泽度
		_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
		//金属性
		[Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
		//金属光泽纹理图
		_MetallicGlossMap("Metallic", 2D) = "white" {}
	//凹凸的尺度
	_BumpScale("Scale", Float) = 1.0
		//法线贴图
		_BumpMap("Normal Map", 2D) = "bump" {}
	//高度缩放尺度
	_Parallax("Height Scale", Range(0.005, 0.08)) = 0.02
		//高度纹理图
		_ParallaxMap("Height Map", 2D) = "black" {}
	//遮挡强度
	_OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
		//遮挡纹理图
		_OcclusionMap("Occlusion", 2D) = "white" {}
	//自发光颜色
	_EmissionColor("Color", Color) = (0,0,0)
		//自发光纹理图
		_EmissionMap("Emission", 2D) = "white" {}
	//细节掩膜图
	_DetailMask("Detail Mask", 2D) = "white" {}
	//细节纹理图
	_DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
	//细节法线贴图尺度
	_DetailNormalMapScale("Scale", Float) = 1.0
		//细节法线贴图
		_DetailNormalMap("Normal Map", 2D) = "bump" {}
	//二级纹理的UV设置
	[Enum(UV0,0,UV1,1)] _UVSec("UV Set for secondary textures", Float) = 0
		//混合状态的定义
		[HideInInspector] _Mode("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0
	}


		CGINCLUDE
#define UNITY_SETUP_BRDF_INPUT MetallicSetup
		ENDCG


		SubShader
	{
		Tags{ "RenderType" = "Opaque" "PerformanceChecks" = "False" }
		LOD 300
		Pass
	{
		Name "FORWARD"
		Tags{ "LightMode" = "ForwardBase" }
		//混合操作：源混合乘以目标混合
		Blend[_SrcBlend][_DstBlend]
		// 根据_ZWrite参数，设置深度写入模式开关与否
		ZWrite[_ZWrite]

		CGPROGRAM
#pragma target 3.0
#pragma exclude_renderers gles
#pragma shader_feature _NORMALMAP
#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
#pragma shader_feature _EMISSION
#pragma shader_feature _METALLICGLOSSMAP 
#pragma shader_feature ___ _DETAIL_MULX2
#pragma shader_feature _PARALLAXMAP 
#pragma multi_compile_fwdbase
#pragma multi_compile_fog
#pragma vertex vertForwardBase
#pragma fragment fragForwardBase
#include "UnityStandardCore.cginc"
		ENDCG
	}

		Pass
	{
		Name "FORWARD_DELTA"
		Tags{ "LightMode" = "ForwardAdd" }
		Blend[_SrcBlend] One
		Fog{ Color(0,0,0,0) }
		ZWrite Off
		ZTest LEqual
		CGPROGRAM
#pragma target 3.0
#pragma exclude_renderers gles
#pragma shader_feature _NORMALMAP
#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
#pragma shader_feature _METALLICGLOSSMAP
#pragma shader_feature ___ _DETAIL_MULX2
#pragma shader_feature _PARALLAXMAP 
#pragma multi_compile_fwdadd_fullshadows 
#pragma multi_compile_fog 
#pragma vertex vertForwardAdd
#pragma fragment fragForwardAdd 
#include "UnityStandardCore.cginc" 
		ENDCG
	}

		Pass
	{
		Name "ShadowCaster"
		Tags{ "LightMode" = "ShadowCaster" }
		ZWrite On
		ZTest LEqual
		CGPROGRAM
#pragma target 3.0
#pragma exclude_renderers gles
#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
#pragma multi_compile_shadowcaster
#pragma vertex vertShadowCaster
#pragma fragment fragShadowCaster
#include "UnityStandardShadow.cginc"
		ENDCG
	}

		Pass
	{
		Name "DEFERRED"
		Tags{ "LightMode" = "Deferred" }
		CGPROGRAM
#pragma target 3.0
#pragma exclude_renderers nomrt gles
#pragma shader_feature _NORMALMAP
#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
#pragma shader_feature _EMISSION
#pragma shader_feature _METALLICGLOSSMAP
#pragma shader_feature ___ _DETAIL_MULX2
#pragma shader_feature _PARALLAXMAP
#pragma multi_compile ___ UNITY_HDR_ON
#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
#pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
#pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON

#pragma vertex vertDeferred
#pragma fragment fragDeferred
#include "UnityStandardCore.cginc"
		ENDCG
	}


//		Pass
//	{
//		Name "META"
//		Tags{ "LightMode" = "Meta" }
//		Cull Off
//		CGPROGRAM
//#pragma vertex vert_meta
//#pragma fragment frag_meta
//#pragma shader_feature _EMISSION
//#pragma shader_feature _METALLICGLOSSMAP
//#pragma shader_feature ___ _DETAIL_MULX2
//
//#include "UnityStandardMeta.cginc"
//		ENDCG
//	}
	}

		//回退Shader为顶点光照Shader
		FallBack "VertexLit"
		//使用特定的自定义编辑器UI界面
		CustomEditor "StandardShaderGUI"
}