terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.4.1"
    }
   
  }
}

resource "kubernetes_namespace" "test" {
  metadata {
    name = "test"
  }
}

resource "kubernetes_service" "example" {
  metadata {
    name = "ingress-service"
    namespace = kubernetes_namespace.test.metadata.0.name
  }
  spec {
    port {
      port = 80
      target_port = 80
      protocol = "TCP"
    }
    type = "NodePort"
  }
  
}


resource "kubernetes_ingress" "example" {
  wait_for_load_balancer = true
  metadata {
    name = "example"
    namespace = kubernetes_namespace.test.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = kubernetes_service.example.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }
}
