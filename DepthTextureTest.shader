Shader "Custom/DepthTextureTest"
{
	CGINCLUDE
#include "UnityCG.cginc"
		sampler2D _CameraDepthTexture;

	fixed4 frag_depth(v2f_img i) : SV_Target
	{
		float depthTextureValue = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
	//float linear01EyeDepth = LinearEyeDepth(depthTextureValue) * _ProjectionParams.w;
	float linear01EyeDepth = Linear01Depth(depthTextureValue);
	return fixed4(linear01EyeDepth, linear01EyeDepth, linear01EyeDepth, 1.0);
	}
		ENDCG

		SubShader
	{
		Pass
		{
			ZTest Off
			Cull Off
			ZWrite Off
			Fog{ Mode Off }

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_depth
			ENDCG
		}
	}
}