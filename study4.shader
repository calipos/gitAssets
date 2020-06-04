// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/study4" 
{
	Properties
	{ 
		[NoScaleOffset] _MainTex("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Pass
	{
		CGPROGRAM
		// use "vert" function as the vertex shader
#pragma vertex vert
		// use "frag" function as the pixel (fragment) shader
#pragma fragment frag

		// vertex shader inputs
		struct appdata
	{
		float4 vertex : POSITION; // vertex position
		float2 uv : TEXCOORD0; // texture coordinate
	};
	struct v2f
	{
		float2 uv : TEXCOORD0; // texture coordinate
		float4 vertex : SV_POSITION; // clip space position
	};
	v2f vert(appdata v)
	{
		v2f o; 
		o.vertex = UnityObjectToClipPos(v.vertex); 
		o.uv = v.uv;
		return o;
	}
	 
	sampler2D _MainTex;

	// pixel shader; returns low precision ("fixed4" type)
	// color ("SV_Target" semantic)
	fixed4 frag(v2f i) : SV_Target
	{
		// sample texture and return it
		fixed4 col = tex2D(_MainTex, i.uv);
	return col;
	}
		ENDCG
	}
	}
}