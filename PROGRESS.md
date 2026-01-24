# Milestone 1: Basic Framework & Initialization

## Goal
Implement the basic framework of `yukicpl` as described in the README, ensuring the initialization process works, configuration is saved, and the main menu is displayed.

## Tasks
- [x] Refactor `yukicpl.sh` to include a working `Init` function that saves configuration.
- [x] Implement `main` function to display the main menu.
- [x] Create a local translation file for testing.
- [x] Implement a basic "System Info" function to verify the framework.
- [x] Ensure `--test` mode works correctly.

## Status
Completed

# Milestone 2: System Management Tools Implementation

## Goal
Implement the "System Management Tools" sub-menu, porting relevant features from the old `yukicpl.sh` script and adapting them to the new `whiptail` UI.

## Tasks
- [x] Create `SystemManagementMenu` function in `yukicpl.sh`.
- [x] Port `tmgr` (System Status) using `htop`.
- [x] Port `bench` (Performance Test) using `bench.sh`.
- [x] Port `lang` (Language Config) using `dpkg-reconfigure locales`.
- [x] Port `timea` (Timezone Config) using `dpkg-reconfigure tzdata`.
- [x] Port `chown` (Fix Permissions) for website directory.
- [x] Implement `clean` (System Cleanup) with appropriate warnings.
- [x] Ensure all functions respect `TestMode` and use `whiptail` for interactions.

## Status
Completed
