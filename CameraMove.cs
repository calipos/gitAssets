using UnityEngine;
using System.Collections;

public class CameraMove : MonoBehaviour
{
    public static Vector3 rotationCenter = new Vector3(0, 0, 0);
    private Vector3 prevAxis = new Vector3(0, 0, 1);
    public float sensitivityMouse = 2f;
    public float sensitivetyKeyBoard = 0.1f;
    public float sensitivetyMouseWheel = 10f;
    public float cameraRadius = 0.0f;
    void Start()
    {
        rotationCenter = new Vector3(0,0,0);
        //cameraRadius = Vector3.magnitude();
        Debug.Log(transform.position);
    }
    public static int setRotationCenter(Vector3 center_)
    {
        rotationCenter = new Vector3(center_.x, center_.y, center_.z);
        return 0;
    }
    void Update()
    {
        if (Input.GetMouseButton(1))
        {
            
            //transform.Rotate(-Input.GetAxis("Mouse Y") * sensitivityMouse, Input.GetAxis("Mouse X") * sensitivityMouse, 0,Space.World);

            float dx = Input.GetAxis("Mouse X") * sensitivityMouse;
            float dy = Input.GetAxis("Mouse Y") * sensitivityMouse;
            float dz = Mathf.Sqrt(dx* dx+ dy* dy);
            if (dz>1)
            {
                Vector3 dragDir = new Vector3(dx / dz, dy / dz, 0);
                Vector3 rotateAxis = Vector3.Cross(dragDir, prevAxis);
                prevAxis = rotateAxis;
                transform.RotateAround(rotationCenter, rotateAxis, dz);
            }
            else
            {

            }
            
        }
        if (Input.GetAxis("Horizontal") != 0)
        {
            Debug.Log(2);
            transform.Translate(Input.GetAxis("Horizontal") * sensitivetyKeyBoard, 0, 0);
        }
        if (Input.GetAxis("Vertical") != 0)
        {
            Debug.Log(3);
            transform.Translate(0, Input.GetAxis("Vertical") * sensitivetyKeyBoard, 0);
        }
        if (Input.GetAxis("Mouse ScrollWheel") < 0)
        {
            if (Camera.main.fieldOfView <= 100)
                Camera.main.fieldOfView += 2;
            if (Camera.main.orthographicSize <= 20)
                Camera.main.orthographicSize += 0.5F;
        }
        if (Input.GetAxis("Mouse ScrollWheel") > 0)
        {
            if (Camera.main.fieldOfView > 2)
                Camera.main.fieldOfView -= 2;
            if (Camera.main.orthographicSize >= 1)
                Camera.main.orthographicSize -= 0.5F;
        }
    }
}


    