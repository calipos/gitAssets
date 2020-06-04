Shader "Custom/19_otherNormMap"
{
	Properties{
		_MainTex("Main Tex", 2D) = "white"{}
	_Color("Color", Color) = (1,1,1,1)   
		_NormalMap("Normal Map", 2D) = "bump"{}
	_BumpScale("Bump Scale", Float) = 1  
	}
		SubShader{
		Pass{
		Tags{ "LightMode" = "ForwardBase" }
		CGPROGRAM
		//  _LightColor0 is hte first direct light and its dir=_WorldSpaceLightPos0
#include "Lighting.cginc" 
#pragma vertex vert
#pragma fragment frag

		fixed4 _Color;
	sampler2D _MainTex;
	float4 _MainTex_ST; 
	sampler2D _NormalMap;
	float4 _NormalMap_ST; 
	float _BumpScale;
	struct a2v
	{
		float4 vertex : POSITION;   
		float3 normal : NORMAL;     
		float4 tangent : TANGENT;   
		float4 texcoord : TEXCOORD0;
	};
	struct v2f
	{
		float4 position : SV_POSITION; 
		float3 lightDir : TEXCOORD0;   
		float3 worldVertex : TEXCOORD1;
		float4 uv : TEXCOORD2;
	};
	v2f vert(a2v v)
	{
		v2f f;
		f.position = UnityObjectToClipPos(v.vertex); 
		f.worldVertex = mul(unity_ObjectToWorld,v.vertex).xyz;
		//f.worldVertex = mul(v.vertex, unity_WorldToObject).xyz;
		f.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw; 
		f.uv.zw = v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
		TANGENT_SPACE_ROTATION; // 调用这个宏会得到一个矩阵rotation，该矩阵用来把模型空间下的方向转换为切线空间下
								//ObjSpaceLightDir(v.vertex); // 得到模型空间下的平行光方向
		f.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)); // 切线空间下，平行光的方向
		return f;
	}

	fixed4 frag(v2f f) : SV_Target
	{		
		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
	fixed4 normalColor = tex2D(_NormalMap, f.uv.zw); 
	fixed3 tangentNormal = UnpackNormal(normalColor);
	tangentNormal.xy = tangentNormal.xy * _BumpScale;
	tangentNormal = normalize(tangentNormal);
	fixed3 lightDir = normalize(f.lightDir); 
	fixed3 texColor = tex2D(_MainTex, f.uv.xy) * _Color.rgb;
	// 漫反射Diffuse颜色 = 直射光颜色 * max(0, cos(光源方向和法线方向夹角)) * 材质自身色彩（纹理对应位置的点的颜色）
	fixed3 diffuse = _LightColor0 * max(0, dot(tangentNormal, lightDir)) * texColor; 
	fixed3 tempColor = diffuse + ambient * texColor; // 最终颜色 = 漫反射 + 环境光 
	return fixed4(tempColor, 1); 
	}

		ENDCG
	}

	}
		FallBack "Diffuse"
}