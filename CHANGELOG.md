# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

## [0.0.3] - 2026-11-17

### Added
- Hierarchical layers with automatic z-index assignment, sibling index validation, and scoped z-index lookup.
- Configurable suppression for info, warning, and error logs through `InfinityEngine`.
- Rigid-body force, impulse, acceleration, gravity scaling, drag, and manual-update controls.

### Changed
- Canvas contents are now derived from the visible layer hierarchy and update when scene or layer state changes.
- Object visual state updates are batched until refreshed, while visibility and layer changes notify listeners immediately.
- Collision handling respects layer collidability and exposes collision events to callbacks.
- Updated README usage and installation guidance.

### Fixed
- Prevented duplicate z-indices among root layers or sibling sublayers, avoiding ambiguous render order.
- Ensured sublayer objects are registered, located, removed, and rendered through recursive layer traversal.

## [0.0.2] - 2026-11-17

### Added
- Curated public libraries for engine, components, physics, and input, alongside the main package library.
- Runnable moving-square Flutter example and updated usage documentation.

### Changed
- Moved implementation libraries under `lib/src` to distinguish internals from the supported public API.

## [0.0.1] - 2026-11-17

### Added
- Initial package release for Infinity Engine.
- Layered object system with z-index support.
- Game loop and tick management via `InfinityLoop` and `InfinityTick`.
- `InfinityObject` state model with transforms, visibility, and color updates.
- Physics primitives including `RigidBody` and `AABBCollider`.
- Input handling support through `InfinityInput`.
- Particle system burst effects.
- Flutter integration through the `Singularity` widget and `runApp` helper.
- Initial documentation and example usage in the README.

### Changed
- Fixed engine startup flow so queued `start()` callbacks execute when the engine begins running.
- Added missing `collection` dependency required by the object API.
- Cleaned up project metadata and package-level documentation for Pub.dev readiness.

### Fixed
- Resolved test failures in the particle system lifecycle.
- Eliminated static analysis warnings blocking publication.
s