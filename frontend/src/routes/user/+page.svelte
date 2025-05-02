<script lang="ts">
  import { Input } from "$lib/components/ui/input";
  import { Button } from "$lib/components/ui/button";
  import { Label } from "$lib/components/ui/label";
  import { Separator } from "$lib/components/ui/separator";
  import { onMount } from "svelte";
  import { getUserDetails, updatePassword } from "$lib/api/apiUser";

  let firstname = "";
  let lastname = "";
  let email = "";
  let phonenumber = "";
  let city = "";
  let address = "";
  let currentPassword = "";
  let password = "";
  let confirmPassword = "";
  let passwordError = "";
  let passwordStrength = "";
  let isLoading = true;
  let isUpdating = false;
  let updateMessage = "";
  let updateSuccess = false;

  onMount(async () => {
    try {
      const userDetails = await getUserDetails();
      firstname = userDetails.firstName || "";
      lastname = userDetails.lastName || "";
      email = userDetails.email || "";
      phonenumber = userDetails.phoneNumber || "";
      city = userDetails.city.name || "";
      address = userDetails.address || "";
    } catch (error) {
      console.error("Error loading user details:", error);
    } finally {
      isLoading = false;
    }
  });

  const handleSubmit = async () => {
    isUpdating = true;
    updateMessage = "";
    updateSuccess = false;

    try {
      // Handle password update if new password is provided
      if (password || confirmPassword || currentPassword) {
        if (!currentPassword) {
          passwordError = "Current password is required";
          return;
        }

        if (!password || !confirmPassword) {
          passwordError = "Both new password and confirmation are required";
          return;
        }

        if (password !== confirmPassword) {
          passwordError = "Passwords do not match";
          return;
        }

        // Check password strength
        if (password.length < 8) {
          passwordStrength = "Weak";
          passwordError = "Password is too weak";
          return;
        }

        try {
          const success = await updatePassword(currentPassword, password);
          if (success) {
            updateSuccess = true;
            updateMessage = "Password updated successfully";
            // Reset password fields
            currentPassword = "";
            password = "";
            confirmPassword = "";
            passwordError = "";
            passwordStrength = "";
          }
        } catch (error) {
          updateSuccess = false;
          updateMessage =
            "Failed to update password. Please check your current password and try again.";
          console.error("Password update error:", error);
        }
      }

      // Process other submitted data here
      console.log("First Name:", firstname);
      console.log("Last Name:", lastname);
      console.log("Email:", email);
      console.log("Phone Number:", phonenumber);
      console.log("City:", city);
      console.log("Address:", address);
    } catch (error) {
      console.error("Form submission error:", error);
      updateSuccess = false;
      updateMessage = "An error occurred while updating your information";
    } finally {
      isUpdating = false;
    }
  };
</script>

<div class="container mx-auto py-10">
  <div class="space-y-6">
    <div>
      <h3 class="text-lg font-medium">Account Settings</h3>
      <p class="text-sm text-muted-foreground">
        Modify your account information below.
      </p>
    </div>

    <Separator />

    <form on:submit|preventDefault={handleSubmit} class="space-y-8">
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
        <div class="space-y-2">
          <Label for="firstname">First Name</Label>
          <Input
            id="firstname"
            type="text"
            placeholder="Enter your first name"
            bind:value={firstname}
          />
        </div>

        <div class="space-y-2">
          <Label for="lastname">Last Name</Label>
          <Input
            id="lastname"
            type="text"
            placeholder="Enter your last name"
            bind:value={lastname}
          />
        </div>

        <div class="space-y-2">
          <Label for="email">Email</Label>
          <Input
            id="email"
            type="email"
            placeholder="Enter your email"
            bind:value={email}
          />
        </div>

        <div class="space-y-2">
          <Label for="phonenumber">Phone Number</Label>
          <Input
            id="phonenumber"
            type="tel"
            placeholder="Enter your phone number"
            bind:value={phonenumber}
          />
        </div>

        <div class="space-y-2">
          <Label for="city">City</Label>
          <Input
            id="city"
            type="text"
            placeholder="Enter your city"
            bind:value={city}
          />
        </div>

        <div class="space-y-2">
          <Label for="address">Address</Label>
          <Input
            id="address"
            type="text"
            placeholder="Enter your address"
            bind:value={address}
          />
        </div>

        <div class="space-y-2">
          <Label for="currentPassword">Current Password</Label>
          <Input
            id="currentPassword"
            type="password"
            placeholder="Enter your current password"
            bind:value={currentPassword}
          />
        </div>

        <div class="space-y-2">
          <Label for="password">New Password</Label>
          <Input
            id="password"
            type="password"
            placeholder="Enter your new password"
            bind:value={password}
          />
        </div>

        <div class="space-y-2">
          <Label for="confirmPassword">Confirm Password</Label>
          <Input
            id="confirmPassword"
            type="password"
            placeholder="Confirm your new password"
            bind:value={confirmPassword}
          />
          {#if passwordError}
            <p class="text-sm text-destructive">{passwordError}</p>
          {/if}
        </div>
      </div>

      {#if passwordStrength}
        <div class="text-sm text-muted-foreground">
          Password Strength: {passwordStrength}
        </div>
      {/if}

      {#if updateMessage}
        <div
          class="text-sm {updateSuccess ? 'text-green-600' : 'text-red-600'}"
        >
          {updateMessage}
        </div>
      {/if}

      <Button type="submit" class="w-full" disabled={isLoading || isUpdating}>
        {isLoading
          ? "Loading..."
          : isUpdating
            ? "Updating..."
            : "Update Account"}
      </Button>
    </form>
  </div>
</div>
