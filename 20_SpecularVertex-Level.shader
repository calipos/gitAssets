// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/20_SpecularVertex-Level"
{
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(1.0, 255)) = 20
	}

		SubShader{
		Pass{
		Tags{
		"LightMode" = "ForwardBase"
	}

		CGPROGRAM

#include "Lighting.cginc"

#pragma vertex vert
#pragma fragment frag

		fixed4 _Diffuse;
	fixed4 _Specular;
	float _Gloss;

	struct a2v {
		float4 pos : POSITION;
		float4 normal : NORMAL;
	};

	struct v2f {
		float4 pos : SV_POSITION;
		fixed3 color : COLOR;
	};

	v2f vert(a2v v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.pos);

		fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

		fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

		fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

		fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.pos).xyz);

		fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normalize(viewDir + worldLightDir), worldNormal)), _Gloss);

		//o.color = UNITY_LIGHTMODEL_AMBIENT.xyz + diffuse + specular;
		o.color = specular;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target{
		return fixed4(i.color, 1.0);
	}

		ENDCG
	}
	}
		Fallback "Specular"
}