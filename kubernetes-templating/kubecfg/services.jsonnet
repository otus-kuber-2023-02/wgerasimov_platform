local kube = import "https://raw.githubusercontent.com/bitnami-labs/kube-libsonnet/master/kube.libsonnet";

local common(name) = {

  service: kube.Service(name) {
    spec+: {
      type: "ClusterIP",
    },
    target_pod:: $.deployment.spec.template,
  },

  deployment: kube.Deployment(name) {
    spec+: {
      template+: {
        spec+: {
          containers_: {
            common: kube.Container("common") {
              env_: {
                PORT: "50051",
              },
              ports_: {  
                containerPort: 50051,
              },
              securityContext: {
                readOnlyRootFilesystem: true,
                runAsNonRoot: true,
                runAsUser: 10001,
              },
              readinessProbe: {
                  initialDelaySeconds: 20,
                  periodSeconds: 15,
                  exec: {
                      command: [
                          "/bin/grpc_health_probe",
                          "-addr=:50051",
                      ],
                  },
              },
              livenessProbe: {
                  initialDelaySeconds: 20,
                  periodSeconds: 15,
                  exec: {
                      command: [
                          "/bin/grpc_health_probe",
                          "-addr=:50051",
                      ],
                  },
              },
            },
          },
        },
      },
    },
  },
};

{
  catalogue: common("paymentservice") {
    service: kube.Service("paymentiservice") {
      target_pod: $.catalogue.deployment.spec.template,
      spec+: {
        selector+: {
          app: "paymentiservice"
        }
      }
    },

    deployment: kube.Deployment("paymentservice") {
      spec+: {
        template+: {
          metadata: {
            labels: {
              app: "paymentservice",
            }
          },
          spec+: {
            containers_+: {
              common+: {
                name: "server",
                image: "gcr.io/google-samples/microservices-demo/paymentservice:v0.1.3",
                ports: [{name: "", containerPort: 50051,}],
              },
            },
          },
        },
      },
    },
  },
  payment: common("shippingservice") {
    service: kube.Service("shippingservice") {
      target_pod: $.catalogue.deployment.spec.template,
      spec+: {
        selector+: {
          app: "shippingservice"
        }
      }
    },
  deployment: kube.Deployment("shippingservice") {
      spec+: {
        template+: {
          metadata: {
            labels: {
              app: "shippingservice",
            }
          },
          spec+: {
            containers_+: {
              common+: {
                name: "server",
                image: "gcr.io/google-samples/microservices-demo/shippingservice:v0.1.3",
                ports: [{name: "grpc", containerPort: 50051,}],
              },
            },
          },
        },
      },
    },
  },
}
