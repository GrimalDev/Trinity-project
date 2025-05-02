export interface Permission {
  resource: string;
  actions: string[]; //"GET", "POST", "PUT", "DELETE"
}
export interface Role {
  name: string;
  permissions: Permission[];
}
export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  roles: Role[];
}

export interface fullUser {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  name: string;
  phoneNumber: string;
  address: string;
  city: City;
  roles: Role[];
}

export interface createUser {
  email: string;
  firstName: string;
  lastname: string;
  phoneNumber: string;
  password: string;
  address: string;
  city: City;
}

export interface City {
  id: string;
  name: string;
  postalCode: number;
  country: string;
}
