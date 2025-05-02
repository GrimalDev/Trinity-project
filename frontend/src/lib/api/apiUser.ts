import { userStore } from "$lib/stores/userStore";
import type { createUser, fullUser, User } from "$lib/types/auth";
import { apiClient, apiClientProtected } from "./api";

async function hashPassword(password: string) {
  const encoder = new TextEncoder();
  const data = encoder.encode(password);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return bufferToHex(hash);
}

function bufferToHex(buffer: ArrayBuffer) {
  return Array.from(new Uint8Array(buffer))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

// Fonction pour valider l'email avec une expression régulière
function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

// Fonction pour valider le mot de passe (longueur, caractère spéciaux, etc.)
function isValidPassword(password: string): boolean {
  // Vérifie si le mot de passe fait au moins 8 caractères et contient un nombre et une lettre
  const passwordRegex = /^(?=.*[a-z])(?=.*\d)(?=.*[@#$%^&-+=()!? "]).{8,128}$/;
  return passwordRegex.test(password);
}

// Example: Fetch users from the API
export const getUsers = async (): Promise<User> => {
  try {
    const response = await apiClientProtected.get(`/user`);
    return response.data;
  } catch (error) {
    console.error("Error fetching users:", error);
    throw error;
  }
};

export const getAllUser = async (): Promise<User[]> => {
  try {
    const response = await apiClientProtected.get(`/user`);
    return response.data;
  } catch (error) {
    console.error("Error fetching users:", error);
    throw error;
  }
};

export const getCurrentUser = async () => {
  try {
    const response = await apiClientProtected.get<User>(`/user/self`);

    userStore.setUser(response.data as User);
  } catch (error) {
    console.error("Error fetching users:", error);
    throw error;
  }
};

export const getUserDetails = async () => {
  try {
    const response = await apiClientProtected.get(`/user/details/self`);
    return response.data;
  } catch (error) {
    console.error("Error fetching user details:", error);
    throw error;
  }
};

// Update user password with front-end hashing
export const updatePassword = async (
  currentPassword: string,
  newPassword: string,
): Promise<boolean> => {
  try {
    // Validate password strength before proceeding
    //if (!isValidPassword(newPassword)) {
    //  throw new Error(
    //    "Password must be at least 8 characters long and contain letters, numbers, and special characters",
    //  );
    //}

    // Hash both passwords before sending
    const hashedCurrentPassword = await hashPassword(currentPassword);
    const hashedNewPassword = await hashPassword(newPassword);

    const response = await apiClientProtected.put("/user/self/password", {
      current_password: hashedCurrentPassword,
      new_password: hashedNewPassword,
    });

    return response.status === 200;
  } catch (error) {
    console.error("Error updating password:", error);
    throw error;
  }
};

// Fonction de création d'un utilisateur
export const createUser = async (
  username: string,
  email: string,
  password: string,
) => {
  if (!isValidEmail(email)) {
    return { data: { errors: { email: ["Invalid email"] } } };
  }

  if (!isValidPassword(password)) {
    return {
      data: {
        errors: {
          password: [
            "Password must be at least 8 characters long, contain at least one letter and one number",
          ],
        },
      },
    };
  }

  try {
    const hashedPassword = await hashPassword(password);
    const response = await apiClient.post("/users/register", {
      user: {
        username,
        email,
        password: hashedPassword,
      },
    });

    return response;
  } catch (error) {
    console.error("Error creating user:", error);
    return error;
  }
};

export const loginUser = async (
  email: string,
  password: string,
): Promise<string | undefined> => {
  try {
    const hashedPassword = await hashPassword(password);
    const response = await apiClient.post("/user/login", {
      email: email,
      password: hashedPassword,
    });
    if (response.status === 200) {
      sessionStorage.setItem("access_token", response.data.token);

      await getCurrentUser();
    } else {
      return "error";
    }
  } catch (error) {
    console.error("Error logging in user:", error);
    return "error";
  }
};

// Example: Update a user
export const updateUser = async (user: User): Promise<boolean> => {
  try {
    await apiClientProtected.put(`/user/${user.id}`, { user });
    return true;
  } catch (error) {
    console.error("Error updating user:", error);
    // throw error;
    return false;
  }
};

// Example: Delete a user
export const deleteUser = async (id: string): Promise<Boolean> => {
  try {
    const response = await apiClientProtected.delete(`/user/${id}`);
    return response.status == 204;
  } catch (error) {
    console.error("Error deleting user:", error);
    // throw error;
    return false;
  }
};

export const createUserAdmin = async (
  user: createUser,
): Promise<fullUser | unknown> => {
  try {
    const response = await apiClientProtected.post(`/user`, { user });
    return response.data;
  } catch (error) {
    console.error(error);
    // return error;
  }
};

export const updateRoleToManager = async (user_id: number) => {
  try {
    const response = await apiClientProtected.get(
      `/gestion/promote_to_manager/${user_id}`,
    );
    return response;
  } catch (error) {
    console.error(error);
    return error;
  }
};

export const updateRoleToUser = async (user_id: number) => {
  try {
    const response = await apiClientProtected.get(
      `/gestion/demote_to_user/${user_id}`,
    );
    return response;
  } catch (error) {
    console.error(error);
    return error;
  }
};

// // reset password
// export const resetPassword = async (
//   password: string,
//   reset_token: LocationQueryValue | LocationQueryValue[],
// ) => {
//   try {
//     const response = await apiClient.put(
//       `/users/reset_password/${reset_token}`,
//       {
//         user: {
//           password: password,
//         },
//       },
//     );
//     return response;
//   } catch (error) {
//     console.error("Error reset password:", error);
//     return error;
//   }
// };
//
// // confirm mail
// export const confirmMail = async (
//   confirm_token: LocationQueryValue | LocationQueryValue[],
// ) => {
//   try {
//     const response = await apiClient.get(`/users/confirm/${confirm_token}`, {});
//     return response;
//   } catch (error) {
//     console.error("Error confirm:", error);
//     return error;
//   }
// };
