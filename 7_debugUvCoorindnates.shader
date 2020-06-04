Shader "Custom/7_debugUvCoorindates"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
	{
		Pass
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200
	CGPROGRAM
	#pragma  vertex vert
	#pragma  fragment frag
#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			struct appdata
			{
				float4 vertex:POSITION;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f
			{
				float4 pos : SV_POSITION; 
				float4 uv:TEXCOORD0;
			};
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = float4(v.texcoord.xy,0,0); 
				return o;
			}
			fixed4 frag(v2f i) :SV_TARGET
			{
				half4 c = 1;
				c.xy = frac(i.uv);
				if (any(saturate(i.uv)-i.uv))
				{
					c.b = 0.5;
				}
				return c;
			}
	ENDCG
		}
 
	}
}
