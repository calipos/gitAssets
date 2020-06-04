Shader "Custom/8_debugShowNorm"
{
    Properties
    {
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
#include "UnityCG.cginc"
		struct v2f
		{
			float4 pos:SV_POSITION;
			float3 norm : NORMAL;
		};
		v2f vert(appdata_base i) 
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			o.norm = UnityObjectToWorldNormal(i.normal);
			return o;
		}
		half3 frag(v2f i) :SV_TARGET
		{
			half3 c = saturate(i.norm * 0.5+0.5);
			//half3 c = frac(i.norm * 2);
			return c;
		}

		ENDCG
			}
    }
    FallBack "Diffuse"
}
