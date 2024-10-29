﻿Shader "Custom/FogEffect"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _PFogColor ("Primary Fog Color", Color) = (1,1,1,1)
        _FogDensity ("Fog Density", Float) = 0.1 // Controls fog intensity
        _FogOffset ("Fog Offset", Float) = 1 // Distance from which fog starts to apply
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _PFogColor;
            float _FogDensity;
            float _FogOffset;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Sample the main texture color
                float4 sceneColor = tex2D(_MainTex, i.uv);

                // Sample and linearize the depth
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                depth = Linear01Depth(depth);

                // Calculate view distance
                float viewDistance = depth * _ProjectionParams.z;

                // Exponential squared fog calculation with an offset
                float fogFactor = (_FogDensity / sqrt(log(2))) * max(0.0f, viewDistance - _FogOffset);
                fogFactor = exp2(-fogFactor * fogFactor);

                // Final fog blending
                float4 finalColor = lerp(_PFogColor, sceneColor, saturate(fogFactor));
                return finalColor;
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
