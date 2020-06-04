Shader "Custom/10_showUv"
{
    Properties
    { 
        _MainTex ("Albedo (RGB)", 2D) = "white" {} 
    }
    SubShader
    { Pass
	{

		Tags { "RenderType" = "Opaque" }
		LOD 200
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

		sampler2D _MainTex;
		float4 _MainTex_ST;
		
		struct v2f 
		{
			float4 pos:SV_POSITION;
			float2 uv : TEXCOORD0;
		};
		v2f vert(appdata_base i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			o.uv = i.texcoord;
			return o;
		}
		fixed4 frag(v2f i):SV_TARGET
		{
			fixed4 c = fixed4(i.uv, 0, 0);
			return c;
		}
		ENDCG
			}
    }
    FallBack "Diffuse"
}
