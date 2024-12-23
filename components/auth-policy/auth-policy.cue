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
			rules: authorization: SOMETHING: opa: externalPolicy: {
				sharedSecretRef: {
					name: "some-name"
					key:  "some-key"
				}
			}
		}
	}
}
