import { get, writable } from "svelte/store";
import type { User, Role, Permission } from "$lib/types/auth";

function createUserStore() {
  const { subscribe, set, update } = writable<User | null>(null);

  const hasPermission = (ressource: string, action?: string) => {
    const user = get(userStore);
    // console.log(user);
    if (!user) return false;

    return user.roles.some((role: Role) => {
      return role.permissions.some((permission: Permission) => {
        const hasResourceAccess =
          permission.resource === "/*" || // global wildcard
          permission.resource === ressource || // exact match
          (permission.resource.endsWith("/*") && // path wildcard
            ressource.startsWith(permission.resource.slice(0, -2)));

        if (!hasResourceAccess || !action) return hasResourceAccess;

        // any action is allowed
        // console.log("test");

        if (action === "*") return true;

        // Check action in the allowed Actions array
        return permission.actions.includes(action);
      });
    });
  };

  return {
    subscribe,
    setUser: (user: User) => set(user),
    clearUser: () => {
      set(null), sessionStorage.removeItem("access_token");
    },
    updateUser: (data: Partial<User>) =>
      update((user) => {
        if (!user) return null;
        return { ...user, ...data };
      }),
    hasPermission: hasPermission,
  };
}

export const userStore = createUserStore();
