# Holos Validation

Question: [Is there some way to validate Kubernetes yaml files?](https://www.reddit.com/r/kubernetes/comments/1hkwewm/is_there_some_way_to_validate_kubernetes_yaml/)

[Holos] offers a solution with CUE:

## Example

Initialize the configuration repository

```
mkdir holos-kuadrant-example && cd holos-kuadrant-example
holos init platform v1alpha5
```

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

Register the custom resource definition as a known resource type so Holos and
CUE automatically validate against it.

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

Create a Holos component to manage the resources you'd like to manage:

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

Verify the schema is being checked, try setting


[Holos]: https://holos.run/docs/overview/
