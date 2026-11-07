using UnityEngine;

namespace Game.Code
{
    public sealed class CameraFacingSprite : MonoBehaviour
    {
        private Transform _cameraTransform;

        private void Awake()
        {
            _cameraTransform = Camera.main!.transform;
        }

        private void LateUpdate()
        {
            if (_cameraTransform == null)
                return;

            transform.rotation = _cameraTransform.rotation;
        }
    }
}
