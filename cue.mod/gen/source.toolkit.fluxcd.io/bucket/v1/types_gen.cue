// Code generated by timoni. DO NOT EDIT.

//timoni:generate timoni vendor crd -f /Users/jeff/Holos/bank-of-holos/tmp/flux/crds.yaml

package v1

import "strings"

// Bucket is the Schema for the buckets API.
#Bucket: {
	// APIVersion defines the versioned schema of this representation
	// of an object.
	// Servers should convert recognized schemas to the latest
	// internal value, and
	// may reject unrecognized values.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
	apiVersion: "source.toolkit.fluxcd.io/v1"

	// Kind is a string value representing the REST resource this
	// object represents.
	// Servers may infer this from the endpoint the client submits
	// requests to.
	// Cannot be updated.
	// In CamelCase.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
	kind: "Bucket"
	metadata!: {
		name!: strings.MaxRunes(253) & strings.MinRunes(1) & {
			string
		}
		namespace!: strings.MaxRunes(63) & strings.MinRunes(1) & {
			string
		}
		labels?: {
			[string]: string
		}
		annotations?: {
			[string]: string
		}
	}

	// BucketSpec specifies the required configuration to produce an
	// Artifact for
	// an object storage bucket.
	spec!: #BucketSpec
}

// BucketSpec specifies the required configuration to produce an
// Artifact for
// an object storage bucket.
#BucketSpec: {
	// BucketName is the name of the object storage bucket.
	bucketName: string
	certSecretRef?: {
		// Name of the referent.
		name: string
	}

	// Endpoint is the object storage address the BucketName is
	// located at.
	endpoint: string

	// Ignore overrides the set of excluded patterns in the
	// .sourceignore format
	// (which is the same as .gitignore). If not provided, a default
	// will be used,
	// consult the documentation for your version to find out what
	// those are.
	ignore?: string

	// Insecure allows connecting to a non-TLS HTTP Endpoint.
	insecure?: bool

	// Interval at which the Bucket Endpoint is checked for updates.
	// This interval is approximate and may be subject to jitter to
	// ensure
	// efficient use of resources.
	interval: =~"^([0-9]+(\\.[0-9]+)?(ms|s|m|h))+$"

	// Prefix to use for server-side filtering of files in the Bucket.
	prefix?: string

	// Provider of the object storage bucket.
	// Defaults to 'generic', which expects an S3 (API) compatible
	// object
	// storage.
	provider?: "generic" | "aws" | "gcp" | "azure" | *"generic"
	proxySecretRef?: {
		// Name of the referent.
		name: string
	}

	// Region of the Endpoint where the BucketName is located in.
	region?: string
	secretRef?: {
		// Name of the referent.
		name: string
	}

	// STS specifies the required configuration to use a Security
	// Token
	// Service for fetching temporary credentials to authenticate in a
	// Bucket provider.
	//
	// This field is only supported for the `aws` and `generic`
	// providers.
	sts?: {
		certSecretRef?: {
			// Name of the referent.
			name: string
		}

		// Endpoint is the HTTP/S endpoint of the Security Token Service
		// from
		// where temporary credentials will be fetched.
		endpoint: =~"^(http|https)://.*$"

		// Provider of the Security Token Service.
		provider: "aws" | "ldap"
		secretRef?: {
			// Name of the referent.
			name: string
		}
	}

	// Suspend tells the controller to suspend the reconciliation of
	// this
	// Bucket.
	suspend?: bool

	// Timeout for fetch operations, defaults to 60s.
	timeout?: =~"^([0-9]+(\\.[0-9]+)?(ms|s|m))+$" | *"60s"
}
