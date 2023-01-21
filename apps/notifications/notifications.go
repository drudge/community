// Package notifications provides details for the Notifications applet.
package notifications

import (
	_ "embed"

	"tidbyt.dev/community/apps/manifest"
)

//go:embed notifications.star
var source []byte

// New creates a new instance of the Notifications applet.
func New() manifest.Manifest {
	return manifest.Manifest{
		ID:          "notifications",
		Name:        "Notifications",
		Author:      "Nick Penree",
		Summary:     "Display notifications",
		Desc:        "Display notifications on your Tidbyt.",
		FileName:    "notifications.star",
		PackageName: "notifications",
		Source:  source,
	}
}
