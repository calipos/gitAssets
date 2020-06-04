using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class cameraMov2 : MonoBehaviour
{

    public enum RotationAxes
    {
        MouseXAndY = 0,
        MouseX = 1,
        MouseY = 2
    }
    public RotationAxes axes = RotationAxes.MouseXAndY;
    public float sensitivityHor = 9f;
    public float sensitivityVert = 9f;

    public float minmumVert = -45f;
    public float maxmumVert = 45f;

    private float _rotationX = 0;
    public float speed = 6.0F;
    public float jumpSpeed = 8.0F;
    public float gravity = 20.0F;
    private Vector3 moveDirection = Vector3.zero;
    //CharacterController controller;
    void Start()
    {
        //controller = GetComponent<CharacterController>();
    }
    void Update()
    {

        if (Input.GetKey(KeyCode.Mouse0) && axes == RotationAxes.MouseX)
        {
            transform.Rotate(0, Input.GetAxis("Mouse X") * sensitivityHor, 0);
        }
        else if (Input.GetKey(KeyCode.Mouse0) && axes == RotationAxes.MouseY)
        {
            _rotationX = _rotationX - Input.GetAxis("Mouse Y") * sensitivityVert;
            _rotationX = Mathf.Clamp(_rotationX, minmumVert, maxmumVert);

            float rotationY = transform.localEulerAngles.y;

            transform.localEulerAngles = new Vector3(-_rotationX, rotationY, 0);
        }
        else if (Input.GetKey(KeyCode.Mouse0))
        {
            _rotationX -= Input.GetAxis("Mouse Y") * sensitivityVert;
            _rotationX = Mathf.Clamp(_rotationX, minmumVert, maxmumVert);

            float delta = Input.GetAxis("Mouse X") * sensitivityHor;
            float rotationY = transform.localEulerAngles.y + delta;

            transform.localEulerAngles = new Vector3(_rotationX, rotationY, 0);
        }
        if (Input.GetAxis("Mouse ScrollWheel") < 0)
        {
            transform.Translate(Vector3.forward * speed / 2 * Time.deltaTime);
        }
        if (Input.GetAxis("Mouse ScrollWheel") > 0)
        {
            transform.Translate(Vector3.back * speed / 2 * Time.deltaTime);
        }
        if (Input.GetKey(KeyCode.W))
        {
            //transform.Translate(Vector3.forward * speed/2 * Time.deltaTime); 
            transform.Translate(Vector3.Cross(Vector3.forward, Vector3.right) * speed / 2 * Time.deltaTime);
        }
        if (Input.GetKey(KeyCode.S))
        {
            //transform.Translate(Vector3.back * speed / 2 * Time.deltaTime);
            transform.Translate(Vector3.Cross(Vector3.forward, Vector3.left) * speed / 2 * Time.deltaTime);
        }
        if (Input.GetKey(KeyCode.A))
        {
            transform.Translate(Vector3.left * speed / 2 * Time.deltaTime);
        }
        if (Input.GetKey(KeyCode.D))
        {
            transform.Translate(Vector3.right * speed / 2 * Time.deltaTime);
        }
    }
}
 