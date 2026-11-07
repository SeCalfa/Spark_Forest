using UnityEngine;

namespace Game.Code
{
    public class ForegroundFadeTrigger : MonoBehaviour
    {
        [SerializeField] private SpriteRenderer targetRenderer;
        [SerializeField] private float visibleAlpha = 1f;
        [SerializeField] private float fadedAlpha = 0.1f;
        [SerializeField] private float speed = 2f;

        private Material _material;
        private float _currentTarget;

        private static readonly int FadeId = Shader.PropertyToID("_Fade");

        private void Awake()
        {
            _material = targetRenderer.material;
            _currentTarget = visibleAlpha;
            _material.SetFloat(FadeId, visibleAlpha);
        }

        private void Update()
        {
            var current = _material.GetFloat(FadeId);
            var next = Mathf.MoveTowards(current, _currentTarget, speed * Time.deltaTime);
            _material.SetFloat(FadeId, next);
        }

        private void OnTriggerEnter(Collider other)
        {
            if (other.CompareTag("Player"))
            {
                print("1");
                _currentTarget = fadedAlpha;
            }
        }

        private void OnTriggerExit(Collider other)
        {
            if (other.CompareTag("Player"))
                _currentTarget = visibleAlpha;
        }
    }
}