using UnityEngine;
using UnityEngine.InputSystem;

namespace Game.Code
{
    public class PlayerMovement : MonoBehaviour
    {
        [Header("Movement")] [SerializeField, Min(0f)]
        private float moveSpeed = 4.2f;

        [SerializeField, Min(0f)] private float acceleration = 24f;
        [SerializeField, Min(0f)] private float deceleration = 32f;

        public Vector3 Velocity => _horizontalVelocity;
        public bool IsMoving => _horizontalVelocity.sqrMagnitude > 0.01f;

        private Camera _camera;
        private CharacterController _controller;
        private InputAction _moveAction;
        private Vector3 _horizontalVelocity;

        private void Awake()
        {
            _camera = Camera.main;
            _controller = GetComponent<CharacterController>();
            _moveAction = new InputAction("Move", expectedControlType: "Vector2");

            _moveAction.AddCompositeBinding("2DVector")
                .With("Up", "<Keyboard>/w")
                .With("Down", "<Keyboard>/s")
                .With("Left", "<Keyboard>/a")
                .With("Right", "<Keyboard>/d");

            _moveAction.AddCompositeBinding("2DVector")
                .With("Up", "<Keyboard>/upArrow")
                .With("Down", "<Keyboard>/downArrow")
                .With("Left", "<Keyboard>/leftArrow")
                .With("Right", "<Keyboard>/rightArrow");

            _moveAction.AddBinding("<Gamepad>/leftStick");
            _moveAction.AddBinding("<Gamepad>/dpad");
        }

        private void OnEnable() => _moveAction?.Enable();

        private void OnDisable() => _moveAction?.Disable();

        private void OnDestroy() => _moveAction?.Dispose();

        private void Update()
        {
            var input = Vector2.ClampMagnitude(_moveAction.ReadValue<Vector2>(), 1f);
            var moveDirection = GetCameraRelativeDirection(input);
            var desiredVelocity = moveDirection * moveSpeed;

            var braking = desiredVelocity.sqrMagnitude < 0.0001f ||
                          Vector3.Dot(_horizontalVelocity, desiredVelocity) < 0f;
            var speedChange = braking ? deceleration : acceleration;

            _horizontalVelocity = Vector3.MoveTowards(
                _horizontalVelocity,
                desiredVelocity,
                speedChange * Time.deltaTime);

            _controller.SimpleMove(_horizontalVelocity);
        }

        private Vector3 GetCameraRelativeDirection(Vector2 input)
        {
            var forward = _camera.transform.forward;
            var right = _camera.transform.right;

            forward.y = 0f;
            right.y = 0f;

            if (forward.sqrMagnitude < 0.0001f)
                forward = Vector3.forward;

            forward.Normalize();
            right.Normalize();

            return Vector3.ClampMagnitude(right * input.x + forward * input.y, 1f);
        }
    }
}
