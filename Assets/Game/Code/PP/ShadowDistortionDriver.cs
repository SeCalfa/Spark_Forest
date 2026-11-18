using UnityEngine;
using UnityEngine.Rendering;

namespace Game.Code.PP
{
    public class ShadowDistortionDriver : MonoBehaviour
    {
        [SerializeField] private Volume shadowVolume;
        [SerializeField] private Material distortionMaterial;

        private static readonly int IntensityId = Shader.PropertyToID("_Intensity");

        private void LateUpdate()
        {
            if (shadowVolume == null || distortionMaterial == null)
                return;

            distortionMaterial.SetFloat(
                IntensityId,
                shadowVolume.weight
            );
        }

        private void OnDisable()
        {
            if (distortionMaterial != null)
                distortionMaterial.SetFloat(IntensityId, 0f);
        }
    }
}
