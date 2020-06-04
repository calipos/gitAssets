using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

public class Node
{
    public Vector3 pos { get;set;}
    public Vector3 dir { get; set; }
    public float length { get; set; }
    public Node() { pos = new Vector3(); dir = new Vector3(); length = 0.01f; }
    public void setDir(Vector3 dirInd)
    { dir = dirInd.normalized; }
    public Vector3 getNextPos()
    {
        Vector3 nectPos =  new Vector3();
        nectPos = pos + length * dir;
        return nectPos;
    }
}
public class HxxSpheres
{
    public int facesNum_;
    public List<List<Node>> HxxUs;
    public HxxSpheres(List<Vector3> pts_, List<int> faces_, List<Vector3> vn_,List<Vector3> faceCenters_, int initialNum)
    {
        HxxUs = new List<List<Node>>();
        facesNum_ = faces_.Count/3;
        for (int i = 0; i < facesNum_; i++)
        {
            List<Node> theFaceU=new List<Node>();
            Vector3 thisFaceCenter = faceCenters_[i];
            
            Vector3 thisNodeHead = thisFaceCenter;
            Vector3 initialDir = vn_[i];
            for (int j = 0; j < initialNum; j++)
            {
                Node thisNode = new Node();
                thisNode.pos = thisNodeHead;
                thisNode.setDir(initialDir);
                thisNode.length = 0.08f;
                theFaceU.Add(thisNode);
                thisNodeHead = thisNode.getNextPos();
            }
            HxxUs.Add(theFaceU);
        }
    }
}
public class importMesh : MonoBehaviour
{
    public string objPath = "";
    public GameObject obj;
    public Mesh mMesh;
    List<Vector3> pts_;
    List<int> faces_;
    List<Vector2> uvs_;
    List<Vector3> vn_;
    List<Vector3> faceCenters_;
    int faceNum;

    GameObject[] m_spheres;
    private MeshFilter mf = null;
    private Vector3 scale;

    HxxSpheres Hxx;
    List<List<GameObject>> HSpheres;

    public int theChosenFaceIdx;
    public int theChosenFaceSphereNum;
    public int theChosenFaceWhichSphereIdx;


    void Start()
    {
        theChosenFaceIdx = -1;
        //--------------------------------------------------------------
        HSpheres = new List<List<GameObject>>();
        m_spheres = new GameObject[3];
        for (int i = 0; i < 3; i++)
        {
            m_spheres[i] = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            m_spheres[i].transform.position = new Vector3(0, 0, 0);
            m_spheres[i].transform.localScale = new Vector3(0.1f, 0.1f, 0.1f);
        }
        //--------------------------------------------------------------
        HSpheres = new List<List<GameObject>>();
        //--------------------------------------------------------------
        objPath = "D:/repo/NewUnityProject/Assets/Resources/objWithUv.obj";
        pts_=new List<Vector3>();
        faces_ = new List<int>();
        uvs_=new List<Vector2>();
        vn_ = new List<Vector3>();
        faceCenters_ = new List<Vector3>();
        FileStream aFile = new FileStream(objPath, FileMode.Open);
        StreamReader reader = new StreamReader(aFile);
        string strLine = reader.ReadLine();
        while (true)
        {
            strLine = reader.ReadLine();
            if (strLine==null)
            {
                break;
            }
            if (strLine.StartsWith("v "))
            { 
                string[] sArray = Regex.Split(strLine, " ", RegexOptions.IgnoreCase);
                float x = float.Parse(sArray[1]);
                float y = float.Parse(sArray[2]);
                float z = float.Parse(sArray[3]); 
                Vector3 thisPt= new Vector3(x,y,z);
                pts_.Add(thisPt);
            }
            else if (strLine.StartsWith("vt "))
            { 
                string[] sArray = Regex.Split(strLine, " ", RegexOptions.IgnoreCase);
                double x = double.Parse(sArray[1]);
                double y = double.Parse(sArray[2]); 
                Vector2 thisUv = new Vector2((float)x, (float)y);
                uvs_.Add(thisUv);
            }
            else if (strLine.StartsWith("#vn "))
            { 
                string[] sArray = Regex.Split(strLine, " ", RegexOptions.IgnoreCase);
                double x = double.Parse(sArray[1]);
                double y = double.Parse(sArray[2]);
                double z = double.Parse(sArray[3]); 
                Vector3 thisN = new Vector3((float)x, (float)y, (float)z);
                vn_.Add(thisN);
            }
            else if (strLine.StartsWith("#faceCenter "))
            { 
                string[] sArray = Regex.Split(strLine, " ", RegexOptions.IgnoreCase);
                double x = double.Parse(sArray[1]);
                double y = double.Parse(sArray[2]);
                double z = double.Parse(sArray[3]); 
                Vector3 thisFaceCenter = new Vector3((float)x, (float)y, (float)z);
                faceCenters_.Add(thisFaceCenter);
            }
            else if (strLine.StartsWith("f "))
            { 
                int ptA = 0;
                int ptB = 0;
                int ptC = 0;
                string[] sArray = Regex.Split(strLine, " ", RegexOptions.IgnoreCase);
                {
                    string[] ptAndUvStrs = Regex.Split(sArray[1], "/", RegexOptions.IgnoreCase);
                    ptA = int.Parse(ptAndUvStrs[0]) - 1;
                }
                {
                    string[] ptAndUvStrs = Regex.Split(sArray[2], "/", RegexOptions.IgnoreCase);
                    ptB = int.Parse(ptAndUvStrs[0]) - 1;
                }
                {
                    string[] ptAndUvStrs = Regex.Split(sArray[3], "/", RegexOptions.IgnoreCase);
                    ptC = int.Parse(ptAndUvStrs[0]) - 1;
                }
                faces_.Add(ptA);
                faces_.Add(ptB);
                faces_.Add(ptC);
                //faces_.Add(ptA);
                //faces_.Add(ptC);
                //faces_.Add(ptB);
            }
            else
            {
                continue;
            }
        }
        reader.Close();        
        Vector3[] pts = pts_.ToArray();
        int[] faces = faces_.ToArray();
        Vector2[]uvs= uvs_.ToArray();
        int num = pts.Length;
        faceNum = num;


        List<Vector3> ptsOrderByX = new List<Vector3>();
        ptsOrderByX = pts_.OrderBy(tt => (tt.x)).ToList();
        List<Vector3> ptsOrderByY = new List<Vector3>();
        ptsOrderByY = pts_.OrderBy(tt => (tt.y)).ToList();
        List<Vector3> ptsOrderByZ = new List<Vector3>();
        ptsOrderByZ = pts_.OrderBy(tt => (tt.z)).ToList();

        Vector3 meshCenter = new Vector3(0.5f * (ptsOrderByX[0].x + ptsOrderByX[num - 1].x),
            0.5f * (ptsOrderByY[0].y + ptsOrderByY[num - 1].y),
            0.5f * (ptsOrderByZ[0].z + ptsOrderByZ[num - 1].z));
        CameraMove.setRotationCenter(meshCenter);

        obj = new GameObject();
        obj.name = "back";
        MeshFilter mfilter_ = obj.AddComponent<MeshFilter>();
        Texture2D t2d = Resources.Load("objWithUv", typeof(Texture2D)) as Texture2D;
        MeshRenderer render_ = obj.AddComponent<MeshRenderer>();
        render_.material = new Material(Shader.Find("Diffuse"));
        render_.material.mainTexture = t2d;
        Mesh mesh = new Mesh();
        mfilter_.mesh = mesh ;
        Color[] colors = new Color[num];
        int[] indecies = new int[num];
        for (int i = 0; i < num; ++i)
        {
            indecies[i] = i;
            colors[i] = Color.white;
        }
        mfilter_.mesh.vertices = pts;
        mfilter_.mesh.uv = uvs;
        mfilter_.mesh.colors = colors;
        //mfilter_.mesh.SetIndices(indecies, MeshTopology.Points, 0);
        mfilter_.mesh.triangles = faces;
        //Debug.Log("done");

        MeshCollider collider = obj.AddComponent<MeshCollider>();
        collider.sharedMesh = mfilter_.mesh;
        //--------------------------------------------------------------
        Hxx = new HxxSpheres(pts_, faces_, vn_, faceCenters_,5);
        for (int i = 0; i < Hxx.HxxUs.Count; i++)
        {
            List<GameObject> thisStrand=new List<GameObject> ();
            for (int j = 0; j < Hxx.HxxUs[i].Count; j++)
            {
                GameObject hs = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                hs.transform.position = Hxx.HxxUs[i][j].pos;
                hs.transform.localScale = new Vector3(0.03f, 0.03f, 0.03f);
                hs.GetComponent<Renderer>().material.color = Color.white;
                thisStrand.Add(hs);
            }
            HSpheres.Add(thisStrand);
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            RaycastHit hit;
            Vector3 mousePos = Input.mousePosition;
            Ray ray = Camera.main.ScreenPointToRay(mousePos);            
            if (Physics.Raycast(ray, out hit, 10000))
            {
                Debug.DrawLine(ray.origin, hit.point, Color.red);
                MeshCollider collider = hit.collider as MeshCollider;
                if (collider == null || collider.sharedMesh == null)
                {
                    theChosenFaceIdx = -1;
                    return;
                }
                Mesh mesh0 = collider.sharedMesh;
                Vector3[] vertices = mesh0.vertices;
                int[] triangles = mesh0.triangles;
                theChosenFaceIdx = hit.triangleIndex;
                Vector3 p0 = hit.transform.TransformPoint(vertices[triangles[theChosenFaceIdx * 3]]);
                Vector3 p1 = hit.transform.TransformPoint(vertices[triangles[theChosenFaceIdx * 3 + 1]]);
                Vector3 p2 = hit.transform.TransformPoint(vertices[triangles[theChosenFaceIdx * 3 + 2]]); 
                Transform transform = collider.transform;                        
                m_spheres[0].transform.position = transform.TransformPoint(p0);
                m_spheres[1].transform.position = transform.TransformPoint(p1);
                m_spheres[2].transform.position = transform.TransformPoint(p2);
                m_spheres[0].GetComponent<Renderer>().material.color = Color.blue;
                m_spheres[1].GetComponent<Renderer>().material.color = Color.green;
                m_spheres[2].GetComponent<Renderer>().material.color = Color.red;
            }
            theChosenFaceSphereNum = HSpheres[theChosenFaceIdx].Count;
            if (theChosenFaceSphereNum < 1)
            {
                theChosenFaceWhichSphereIdx = -1;
            }
            else
            {
                theChosenFaceWhichSphereIdx = 0;
            }
            for (int faceId = 0; faceId < HSpheres.Count; faceId++)
            {
                if (faceId== theChosenFaceIdx)
                {
                    for (int i = 0; i < HSpheres[faceId].Count; i++)
                    {
                        if (theChosenFaceWhichSphereIdx == i) 
                        {
                            HSpheres[faceId][theChosenFaceWhichSphereIdx].GetComponent<Renderer>().material.color = new Color(1.0f, 1.0f, 0, 1.0f);
                        }
                        else
                        {
                            HSpheres[faceId][i].GetComponent<Renderer>().material.color = new Color(0.0f, 1.0f, 1, 1.0f);
                        }
                    }                    
                }
                else
                {
                    for (int i = 0; i < HSpheres[faceId].Count; i++)
                    {
                        HSpheres[faceId][i].GetComponent<Renderer>().material.color = new Color(.2f, .2f, .2f, .2f);
                    }
                }
            }
            
        }

        if (Input.GetKeyDown(KeyCode.Equals) && theChosenFaceIdx >= 0)
        {
            Debug.Log("+");
        }
        if (Input.GetKeyDown(KeyCode.Minus) && theChosenFaceIdx >= 0)
        {
            Debug.Log("-");
        }
        if (theChosenFaceIdx != -1) 
        {

        }
        if (Time.frameCount % 2 == 0)
        {

        }
    }


    

}
