using UnityEngine;

namespace Game.Code
{
    public class CameraFollow : MonoBehaviour
    {
        [SerializeField] private Transform target;

        [Header("Camera Framing")]
        [SerializeField] private Vector3 offset = new(0f, 9f, -9f);
        [SerializeField] private float lookAtHeight = 0.8f;

        [Header("Following")]
        [SerializeField, Min(0.01f)] private float smoothTime = 0.15f;

        private Vector3 _followVelocity;

        private void Start()
        {
            transform.position = target.position + offset;

            var lookDirection = target.position + Vector3.up * lookAtHeight - transform.position;
            transform.rotation = Quaternion.LookRotation(lookDirection.normalized, Vector3.up);
        }

        private void LateUpdate()
        {
            if (target == null)
                return;

            var desiredPosition = target.position + offset;
            transform.position = Vector3.SmoothDamp(
                transform.position,
                desiredPosition,
                ref _followVelocity,
                smoothTime);
        }
    }
}
