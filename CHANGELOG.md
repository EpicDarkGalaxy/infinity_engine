# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

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
- Curated public libraries for engine, components, physics, and input, alongside the main package library.
- Runnable moving-square Flutter example and updated usage documentation.

### Changed
- Moved implementation libraries under `lib/src` to distinguish internals from the supported public API.
- Fixed engine startup flow so queued `start()` callbacks execute when the engine begins running.
- Added missing `collection` dependency required by the object API.
- Cleaned up project metadata and package-level documentation for Pub.dev readiness.

### Fixed
- Resolved test failures in the particle system lifecycle.
- Eliminated static analysis warnings blocking publication.
s