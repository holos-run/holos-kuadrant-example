// Code generated by timoni. DO NOT EDIT.

//timoni:generate timoni vendor crd -f /Users/jeff/Holos/bank-of-holos/tmp/flux/crds.yaml

package v1beta2

import "strings"

// ImagePolicy is the Schema for the imagepolicies API
#ImagePolicy: {
	// APIVersion defines the versioned schema of this representation
	// of an object.
	// Servers should convert recognized schemas to the latest
	// internal value, and
	// may reject unrecognized values.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
	apiVersion: "image.toolkit.fluxcd.io/v1beta2"

	// Kind is a string value representing the REST resource this
	// object represents.
	// Servers may infer this from the endpoint the client submits
	// requests to.
	// Cannot be updated.
	// In CamelCase.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
	kind: "ImagePolicy"
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

	// ImagePolicySpec defines the parameters for calculating the
	// ImagePolicy.
	spec!: #ImagePolicySpec
}

// ImagePolicySpec defines the parameters for calculating the
// ImagePolicy.
#ImagePolicySpec: {
	// FilterTags enables filtering for only a subset of tags based on
	// a set of
	// rules. If no rules are provided, all the tags from the
	// repository will be
	// ordered and compared.
	filterTags?: {
		// Extract allows a capture group to be extracted from the
		// specified regular
		// expression pattern, useful before tag evaluation.
		extract?: string

		// Pattern specifies a regular expression pattern used to filter
		// for image
		// tags.
		pattern?: string
	}

	// ImageRepositoryRef points at the object specifying the image
	// being scanned
	imageRepositoryRef: {
		// Name of the referent.
		name: string

		// Namespace of the referent, when not specified it acts as
		// LocalObjectReference.
		namespace?: string
	}

	// Policy gives the particulars of the policy to be followed in
	// selecting the most recent image
	policy: {
		alphabetical?: {
			// Order specifies the sorting order of the tags. Given the
			// letters of the
			// alphabet as tags, ascending order would select Z, and
			// descending order
			// would select A.
			order?: "asc" | "desc" | *"asc"
		}
		numerical?: {
			// Order specifies the sorting order of the tags. Given the
			// integer values
			// from 0 to 9 as tags, ascending order would select 9, and
			// descending order
			// would select 0.
			order?: "asc" | "desc" | *"asc"
		}
		semver?: {
			// Range gives a semver range for the image tag; the highest
			// version within the range that's a tag yields the latest image.
			range: string
		}
	}
}
