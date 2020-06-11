Shader "Custom/9_debugShowBiTagent"
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
				float4 pos : SV_POSITION;
				float3 norm : NORMAL;
			};
			v2f vert(appdata_tan i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.norm = cross(UnityObjectToWorldNormal(i.tangent), UnityObjectToWorldNormal(i.normal));
				//o.color.w = 1.;
				return o;
			}
			half3 frag(v2f i):SV_TARGET
			{
				//half3 c = i.color;
				half3 c = saturate(i.norm * 0.5 + 0.5);
			 //c.x = i.color.x;
			 //c.y = i.color.y;
			 //c.z = i.color.z;
			 //c.w = 1.;
				return c;
			}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
