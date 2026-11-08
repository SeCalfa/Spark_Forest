
Shader "SparkForest/Post/ShadowDistortion"
{
    Properties
    {
        _Intensity ("Intensity", Range(0, 1)) = 0
        _DistortionPixels ("Distortion Pixels", Range(0, 4)) = 1.5
        _Speed ("Speed", Range(0, 5)) = 0.7
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            ZWrite Off
            ZTest Always
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float _Intensity;
                float _DistortionPixels;
                float _Speed;
            CBUFFER_END

            half4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.texcoord;

                // Stronger distortion near screen edges.
                float2 center = uv * 2.0 - 1.0;
                float edge = smoothstep(
                    0.2, 1.0, length(center)
                );

                // Two slow waves.
                float wave =
                    sin(uv.y * 45.0 + _Time.y * _Speed) * 0.6 +
                    sin(uv.y * 97.0 - _Time.y * _Speed * 1.4) * 0.4;

                float offsetPixels =
                    wave * edge * _DistortionPixels * _Intensity;

                uv.x += offsetPixels / _ScreenParams.x;

                return SAMPLE_TEXTURE2D_X(
                    _BlitTexture,
                    sampler_LinearClamp,
                    saturate(uv)
                );
            }
            ENDHLSL
        }
    }
}
