Shader "Custom/show_Normals"
{
	Properties
	{
		_LineLength("LineLength",float) = 0.03
		_LineColor("LineColor",COLOR) = (1,0,0,1)
	}
		SubShader
	{
		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

		struct v2f {
		// we'll output world space normal as one of regular ("texcoord") interpolators
		half3 worldNormal : TEXCOORD0;
		float4 pos : SV_POSITION;
	};

	// vertex shader: takes object space normal as input too
	v2f vert(float4 vertex : POSITION, float3 normal : NORMAL)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(vertex);
		// UnityCG.cginc file contains function to transform
		// normal from object to world space, use that
		o.worldNormal = UnityObjectToWorldNormal(normal);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 c = 0;
	// normal is a 3D vector with xyz components; in -1..1
	// range. To display it as color, bring the range into 0..1
	// and put into red, green, blue components
	c.rgb = i.worldNormal*0.5 + 0.5;
	return c;
	}
		ENDCG
	}
		Pass
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
#pragma target 5.0
#pragma vertex VS_Main
#pragma fragment FS_Main
#pragma geometry GS_Main
#include "UnityCG.cginc"

		float _LineLength;
	fixed4 _LineColor;


	struct GS_INPUT
	{
		float4    pos       : POSITION;
		float3    normal    : NORMAL;
		float2  tex0        : TEXCOORD0;
	};
	struct FS_INPUT
	{
		float4    pos       : POSITION;
		float2  tex0        : TEXCOORD0;
	};
	//step1
	GS_INPUT VS_Main(appdata_base v)
	{
		GS_INPUT output = (GS_INPUT)0;
		output.pos = mul(unity_ObjectToWorld, v.vertex);
		//output.pos = UnityObjectToClipPos(v.vertex);
		output.normal = v.normal;
		//float4 viewNormal = mul(UNITY_MATRIX_IT_MV, float4(v.normal, 0));
		float3 worldNormal = UnityObjectToWorldNormal(v.normal);
		output.normal = normalize(worldNormal);
		output.tex0 = float2(0, 0);
		return output;
	}
	[maxvertexcount(4)]
	void GS_Main(point GS_INPUT p[1], inout LineStream<FS_INPUT> triStream)
	{
		FS_INPUT pIn;
		pIn.pos = mul(UNITY_MATRIX_VP, p[0].pos);// UnityObjectToClipPos(p[0].pos);
		pIn.tex0 = float2(0.0f, 0.0f);
		triStream.Append(pIn);
		FS_INPUT pIn1;
		float4 pos = p[0].pos + float4(p[0].normal,0) *_LineLength;
		pIn1.pos = mul(UNITY_MATRIX_VP, pos);
		pIn1.tex0 = float2(0.0f, 0.0f);
		triStream.Append(pIn1);

	}

	//step3
	fixed4 FS_Main(FS_INPUT input) : COLOR
	{
		return _LineColor;
	}
		ENDCG
	}
	}
}