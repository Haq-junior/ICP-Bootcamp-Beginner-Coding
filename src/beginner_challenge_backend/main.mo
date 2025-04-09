import Result "mo:base/Result";
import Text "mo:base/Text";
import Array "mo:base/Array";

actor {
    // Define a type for UserProfile
    type UserProfile = {
        id : Nat;
        name : Text;
        results : [Text];
    };

    // In-memory storage for user profiles
    var userProfiles : [UserProfile] = [];

    // Helper function to find a user profile by ID
    func findUserProfile(id : Nat) : ?UserProfile {
        return Array.find<UserProfile>(userProfiles, func (profile) { profile.id == id });
    };

    // Helper function to update or insert a user profile
    func upsertUserProfile(profile : UserProfile) {
        let existingProfile = findUserProfile(profile.id);
        switch (existingProfile) {
            case (?_) {
                // Update existing profile
                userProfiles := Array.map<UserProfile, UserProfile>(
                    userProfiles,
                    func (p) { if (p.id == profile.id) profile else p }
                );
            };
            case null {
                // Add new profile
                userProfiles := Array.append<UserProfile>(userProfiles, [profile]);
            };
        };
    };

    public query ({ caller = _ }) func getUserProfile() : async Result.Result<{ id : Nat; name : Text }, Text> {
        switch (findUserProfile(123)) {
            case (?profile) return #ok({ id = profile.id; name = profile.name });
            case null return #err("User not found");
        };
    };

    public shared ({ caller = _ }) func setUserProfile(name : Text) : async Result.Result<{ id : Nat; name : Text }, Text> {
        let profile = { id = 123; name = name; results = [] };
        upsertUserProfile(profile);
        return #ok({ id = profile.id; name = profile.name });
    };

    public shared ({ caller = _ }) func addUserResult(result : Text) : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        switch (findUserProfile(123)) {
            case (?profile) {
                let updatedProfile = { id = profile.id; name = profile.name; results = Array.append<Text>(profile.results, [result]) };
                upsertUserProfile(updatedProfile);
                return #ok({ id = updatedProfile.id; results = updatedProfile.results });
            };
            case null return #err("User not found");
        };
    };

    public query ({ caller = _ }) func getUserResults() : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        switch (findUserProfile(123)) {
            case (?profile) return #ok({ id = profile.id; results = profile.results });
            case null return #err("User not found");
        };
    };
};
