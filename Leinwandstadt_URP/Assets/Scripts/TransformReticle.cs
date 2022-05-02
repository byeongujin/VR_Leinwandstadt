using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TransformReticle : MonoBehaviour
{
    public float speed = 1;
    void Update()
    {
        transform.Rotate(Vector3.up * speed * Time.deltaTime);
    }
}
