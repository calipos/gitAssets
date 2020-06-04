Shader "Custom/light_1_diffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Cutoff" }
        LOD 200
        CGPROGRAM
        #pragma surface surf Lambert
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };
		 

        void surf (Input IN, inout SurfaceOutput  o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb; 
        }
        ENDCG
    }
    FallBack "Diffuse"
}
