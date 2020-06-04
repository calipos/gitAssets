using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreatMesh : MonoBehaviour
{
    
    private int height_;
    private int width_;

    public Vector3[] vertexes;//顶点数
    public Vector3[] norms;
    public Vector2[] uvs;//uvs坐标
    public int[] triangles;//三角形索引
    public GameObject obj;
    MeshFilter mfilter_;
    MeshRenderer render_;
    MeshCollider collider_;
    Texture2D t2d;
    void Start()
    {
        creatMesh(255, 255);
        vertexes = computeVertexes();
        triangles = GetTriangles();
        uvs = computeUV();
        norms = computeNorm();
        t2d = Resources.Load("earth", typeof(Texture2D)) as Texture2D;

        obj = new GameObject();
        obj.name = "self_obj";
        mfilter_ = obj.AddComponent<MeshFilter>();
        render_ = obj.AddComponent<MeshRenderer>();
        render_.material = new Material(Shader.Find("Diffuse"));
        render_.material.mainTexture = t2d;
        Mesh mesh = mfilter_.mesh;
        mesh.vertices = vertexes;// computeVertexes();
        mesh.triangles = triangles;// GetTriangles();
        mesh.uv = uvs;// computeUV();
        mesh.normals = norms;// computeNorm();
        collider_ = obj.AddComponent<MeshCollider>();
        collider_.sharedMesh = mesh;
        //collider_.convex = true;
    }

    void Update()
    {
        //render_.material = new Material(Shader.Find("Diffuse"));
        //render_.material.mainTexture = t2d;
        //Mesh mesh = mfilter_.mesh;
        //mesh.vertices = computeVertexes();
        //mesh.triangles = GetTriangles();
        //mesh.uv = computeUV();
        //mesh.normals = computeNorm();
        //collider_ = obj.AddComponent<MeshCollider>();
        //collider_.sharedMesh = mesh;
        ////collider_.convex = true;
        int index = 0;
        for (int i = -height_ / 2; i < height_ - height_ / 2; i++)
        {
            for (int j = -width_ / 2; j < width_ - width_ / 2; j++)
            {
                vertexes[index].y = Random.Range(-0.01f, 0.01f);
                index++;
            }
        }
        mfilter_.mesh.vertices = vertexes;
    }
    private void creatMesh(int width, int height)
    {        
        height_ = height;
        width_ = width;
        
    }

    private Vector3[] computeVertexes()
    {        
        GetTriangles();
        int index = 0;
        Vector3[]vertexes = new Vector3[height_* width_];
        
        for (int i = -height_/2; i < height_- height_ / 2; i++)
        {
            for (int j = -width_ / 2; j < width_- width_/2; j++)
            {
                float x =  0.02f*j;
                float z = 0.02f * i;
                float y = 0.2f-(x * x / 9 + z * z / 16);
                //float y = 100.2f - x - z;
                vertexes[index] = new Vector3(x, Random.Range(-0.1f, 0.1f), z);
                index++;
            }
        }
        return  vertexes;
    }
    private Vector2[] computeUV()
    {
        Vector2[]uvs = new Vector2[height_* width_];
        int index = 0;
        for (int i = 0; i < height_; i++) 
        {
            for (int j = 0; j < width_; j++) 
            {
                
                float x = 1.0f * j/(width_-1); 
                float y = 1.0f * i / (height_ - 1);
                uvs[index] = new Vector2(x,y);
                index++;
            }
        }
        return uvs;
    }

    private Vector3[] computeNorm()
    {
        Vector3[]norms = new Vector3[height_ * width_];
        int index = 0;
        for (int i = 0; i < height_; i++)
        {
            for (int j = 0; j < width_; j++)
            {
                float a = Random.Range(-0.8f, 0.8f);
                float b = Random.Range(-0.8f, 0.8f);
                float c = Mathf.Sqrt(1 - a * a - b * b);
                //norms[index] = new Vector3(a,b,c);
                norms[index] = new Vector3(0, 1, 0);
                index++;
            }
        }
        return norms;
    }
    
    private int[] GetTriangles()
    {
        int[]triangles = new int[3*2*(height_-1)*(width_-1)];
        uint index = 0;
        for (int i = 0; i < height_; i++)
        {
            for (int j = 0; j < width_; j++)
            {
                if (i==height_-1 || j==width_-1)
                {
                    continue;
                }
                int a = width_ * i + j;
                int b = width_ * i + j+1;
                int c = width_ * i + j+ width_;
                int d = width_ * i + j+ width_+1;
                triangles[index] = a;
                triangles[index + 1] = c;
                triangles[index + 2] = d;
                triangles[index + 3] = d;
                triangles[index + 4] = b;
                triangles[index + 5] = a;

                //triangles[index+6] = a;
                //triangles[index + 7] = d;
                //triangles[index + 8] = c;
                //triangles[index + 9] = a;
                //triangles[index + 10] = b;
                //triangles[index + 11] = d;
                index += 6;
            }
        }
        return triangles;
    }
    
}