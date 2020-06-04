using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
    public Transform m_transform;
    
    public GameObject myCube;
    public GameObject myCube2;
    public float rotaSpeed = 9.5f;
    GameObject[] m_cubes;
    private int m_cubes_num;


    // Start is called before the first frame update
    void Start()
    {

        myCube = GameObject.CreatePrimitive(PrimitiveType.Cube);
        myCube.AddComponent<Rigidbody>();
        myCube.GetComponent<Renderer>().material.color = Color.red;
        myCube.transform.position = new Vector3(0, 0.5f, 0);
        myCube2 = GameObject.CreatePrimitive(PrimitiveType.Cube);
        myCube2.AddComponent<Rigidbody>();
        myCube2.GetComponent<Renderer>().material.color = Color.magenta;
        myCube2.transform.position = new Vector3(2, .5f, 1.5f);

        m_cubes_num = 10;
        m_cubes = new GameObject[m_cubes_num];
        for (int i = 0; i < m_cubes_num; i++)
        {
            m_cubes[i] = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            m_cubes[i].AddComponent<Rigidbody>();
            m_cubes[i].GetComponent<Renderer>().material.color = Color.cyan;
            m_cubes[i].transform.position = new Vector3(Random.Range(-0.8f, 0.8f), 2.2f, Random.Range(-0.8f, 0.8f));
            m_cubes[i].transform.localScale = new Vector3(0.1f, 0.1f, 0.1f);            
        }
        
        return;
    }

    // Update is called once per frame
    void Update()
    {
        
        for (int i = 0; i < m_cubes_num; i++)
        {
            if (m_cubes[i].transform.position.y<-1)
            {
                m_cubes[i].transform.position = new Vector3(Random.Range(-0.8f, 0.8f), 2.2f, Random.Range(-0.8f, 0.8f));
            }
        }
        
        myCube.transform.Rotate(Vector3.up * rotaSpeed, Space.World);
        myCube2.transform.Rotate(Vector3.up * rotaSpeed, Space.World);
        
        Vector3 currXYZ = myCube2.transform.position;
        if (Input.GetKey(KeyCode.W))
        {
            currXYZ.x += 0.2f;
            myCube2.transform.position = currXYZ;
        }
        else if (Input.GetKey(KeyCode.S))
        {
            currXYZ.x -= 0.2f;
            myCube2.transform.position = currXYZ;
        }
        if (Input.GetKey(KeyCode.A))
        {
            currXYZ.z += 0.2f;
            myCube2.transform.position = currXYZ;
        }
        else if (Input.GetKey(KeyCode.D))
        {
            currXYZ.z -= 0.2f;
            myCube2.transform.position = currXYZ;
        }
        return;
    }
    void OnGUI()
    {

        if (GUILayout.Button("CreateCube", GUILayout.Height(50), GUILayout.Width(100)))
        {

            GameObject m_cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            m_cube.AddComponent<Rigidbody>();
            m_cube.GetComponent<Renderer>().material.color = Color.blue;
            m_cube.transform.position = new Vector3(0, 10, 0);
        }
        if (GUILayout.Button("CreateSphere", GUILayout.Height(50)))
        {         
                GameObject m_cube = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                m_cube.AddComponent<Rigidbody>();
                m_cube.GetComponent<Renderer>().material.color = Color.blue;                
                m_cube.transform.position = new Vector3(0.6f, 1.2f, 0.0f);
                m_cube.transform.localScale = new Vector3(0.1f, 0.1f, 0.1f);     
        }
    }


}
