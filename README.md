# Holos Validation

Question: [Is there some way to validate Kubernetes yaml files?](https://www.reddit.com/r/kubernetes/comments/1hkwewm/is_there_some_way_to_validate_kubernetes_yaml/)

[Holos] offers a solution with CUE:

## Example

Initialize the configuration repository

```
mkdir holos-kuadrant-example && cd holos-kuadrant-example
holos init platform v1alpha5
```

### Import the CRD

Import the CRDs to validate against.

```bash
kustomize build https://github.com/Kuadrant/kuadrant-operator/config/crd > crds.yaml
timoni mod vendor crds -f crds.yaml
```

```txt
2:27PM INF schemas vendored: kuadrant.io/authpolicy/v1
2:27PM INF schemas vendored: kuadrant.io/dnspolicy/v1
2:27PM INF schemas vendored: kuadrant.io/kuadrant/v1beta1
2:27PM INF schemas vendored: kuadrant.io/ratelimitpolicy/v1
2:27PM INF schemas vendored: kuadrant.io/tlspolicy/v1
```

### Register AuthPolicy

Register `AuthPolicy` as a known resource type so Holos and CUE automatically
validate resources against the schema.

```
cat <<EOF > kuadrant.cue
```
```cue
package holos

import authpolicy "kuadrant.io/authpolicy/v1"

#Resources: AuthPolicy?: [_]: authpolicy.#AuthPolicy
```
```bash
EOF
```

### Define a Holos Component

Define a Holos component to manage the resources as you like.

```bash
mkdir -p components/auth-policy
cat <<EOF > components/auth-policy/auth-policy.cue
```
```cue
package holos

holos: Component.BuildPlan

Component: #Kubernetes & {
	Resources: AuthPolicy: example: {
		metadata: {
			name:      "example"
			namespace: "default"
		}
		spec: {
			targetRef: {
				kind:  "SomeKind"
				group: "some-group"
				name:  "some-name"
			}
		}
	}
}
```
```bash
EOF
```

### Add the Component

Add the component to the platform:

```bash
cat <<EOF > platform/auth-policy.cue
```
```cue
package holos

Platform: Components: "auth-policy": {
	name: "auth-policy"
	path: "components/auth-policy"
}
```
```
EOF
```

### Render the Configuration

Render the configuration (rendered manifests pattern)

```bash
holos render platform
```
```txt
rendered auth-policy in 193.570292ms
rendered platform in 194.134167ms
```

The resulting manifest is:

```
cat deploy/components/auth-policy/auth-policy.gen.yaml
```
```yaml
apiVersion: kuadrant.io/v1
kind: AuthPolicy
metadata:
  name: example
  namespace: default
spec:
  targetRef:
    group: some-group
    kind: SomeKind
    name: some-name
```

### Verify against the Schema

Verify the schema is being checked, try setting the `spec.opa` field as described.

```bash
patch -p1 <<EOF
```
```diff
diff --git a/components/auth-policy/auth-policy.cue b/components/auth-policy/auth-policy.cue
index 344abc9..7aad229 100644
--- a/components/auth-policy/auth-policy.cue
+++ b/components/auth-policy/auth-policy.cue
@@ -14,6 +14,7 @@ Component: #Kubernetes & {
 				group: "some-group"
 				name:  "some-name"
 			}
+			rules: authorization: opa: externalPolicy: sharedSecretRef: {}
 		}
 	}
 }
```
```
EOF
```

Now `holos` gives an error

```txt
could not run: holos.spec.artifacts.0.generators.0.resources.AuthPolicy.example.spec.rules.authorization.opa.externalPolicy: field not allowed at internal/builder/instance.go:123
holos.spec.artifacts.0.generators.0.resources.AuthPolicy.example.spec.rules.authorization.opa.externalPolicy: field not allowed:
    /Users/jeff/Holos/holos-kuadrant-example/components/auth-policy/auth-policy.cue:3:8
    /Users/jeff/Holos/holos-kuadrant-example/components/auth-policy/auth-policy.cue:17:31
    /Users/jeff/Holos/holos-kuadrant-example/cue.mod/gen/kuadrant.io/authpolicy/v1/types_gen.cue:44:9
    /Users/jeff/Holos/holos-kuadrant-example/cue.mod/gen/kuadrant.io/authpolicy/v1/types_gen.cue:4337:14
    /Users/jeff/Holos/holos-kuadrant-example/cue.mod/pkg/github.com/holos-run/holos/api/author/v1alpha5/definitions.cue:56:17
    /Users/jeff/Holos/holos-kuadrant-example/cue.mod/pkg/github.com/holos-run/holos/api/author/v1alpha5/definitions.cue:184:41
    /Users/jeff/Holos/holos-kuadrant-example/kuadrant.cue:5:31
    /Users/jeff/Holos/holos-kuadrant-example/schema.cue:8:13
could not run: could not render component: could not run command:
        holos '--log-level' 'info' '--log-format' 'console' 'render' 'component' '--inject' 'holos_component_name=auth-policy' '--inject' 'holos_component_path=components/auth-policy' './components/auth-policy'
        exit status 1 at cli/render/render.go:171
```

### Seeing the problem

> [!NOTE]
> The error leads us to [kuadrant.io/authpolicy/v1/types_gen.cue:4337:14](https://github.com/holos-run/holos-kuadrant-example/blob/main/cue.mod/gen/kuadrant.io/authpolicy/v1/types_gen.cue#L4337)

> [!IMPORTANT]
> We see `authorization: [string]: opa: {...}` indicating there's an
> intermediate field between the `authorization` and `opa` fields. It should look
> like `spec.rules.authorization.SOMETHING.opa.externalPolicy`.

Try it out:

```bash
patch -p1 <<EOF
```
```diff
diff --git a/components/auth-policy/auth-policy.cue b/components/auth-policy/auth-policy.cue
index ad460f5..6b2c410 100644
--- a/components/auth-policy/auth-policy.cue
+++ b/components/auth-policy/auth-policy.cue
@@ -14,7 +14,12 @@ Component: #Kubernetes & {
 				group: "some-group"
 				name:  "some-name"
 			}
-			rules: authorization: opa: externalPolicy: sharedSecretRef: {}
+			rules: authorization: SOMETHING: opa: externalPolicy: {
+				sharedSecretRef: {
+					name: "some-name"
+					key:  "some-key"
+				}
+			}
 		}
 	}
 }
```
```bash
EOF
```

### Render the configs again

Now the schema is valid and it renders again.

```bash
holos render platform
```
```txt
rendered auth-policy in 193.570292ms
rendered platform in 194.134167ms
```

```bash
cat deploy/components/auth-policy/auth-policy.gen.yaml
```
```yaml
apiVersion: kuadrant.io/v1
kind: AuthPolicy
metadata:
  name: example
  namespace: default
spec:
  rules:
    authorization:
      SOMETHING:
        opa:
          externalPolicy:
            sharedSecretRef:
              key: some-key
              name: some-name
  targetRef:
    group: some-group
    kind: SomeKind
    name: some-name
```

[Holos]: https://holos.run/docs/overview/
