Shader "Custom/14_controlBaseRgb"
{
    Properties
    {
		_ColorA("ColorA", Color) = (1,1,1,1)
		_ColorB("ColorB", Color) = (0,0,0,1)
		_Density("Density", Range(2,50)) = 30
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

		struct appdata
	{
		float4 vertex:POSITION;
		float2 uv:TEXCOORD0;
	};
	struct v2f
	{
		float4 pos:SV_POSITION;
		float2 uv:TEXCOORD0;
	};
float _Density;
fixed4 _ColorA;
fixed4 _ColorB;
		v2f vert(appdata i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			o.uv = i.uv;
			return o;
		}
		fixed4 frag(v2f i) :SV_TARGET
		{
			if ((floor(_Density*i.uv.x) + floor(_Density*i.uv.y)) % 2)
			return _ColorA;
			else return _ColorB;
		}
		ENDCG
			}
    }
    FallBack "Diffuse"
}
