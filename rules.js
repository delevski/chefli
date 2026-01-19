// InstantDB Rules - defines permissions for data access
const rules = {
  users: {
    $: {
      // Users can read their own data
      'read': (ctx, { id }) => ctx.auth.id === id,
      // Users can update their own data
      'write': (ctx, { id }) => ctx.auth.id === id,
      // Users cannot create or delete user records (handled by auth system)
      'create': false,
      'delete': false,
    },
  },
  recipes: {
    $: {
      // Anyone can read recipes (public recipes)
      'read': true,
      // Allow writes for now (we'll filter by userId in the app)
      'write': true,
      // Allow creates for now (we'll set userId in the app)
      'create': true,
      // Allow deletes for now (we'll filter by userId in the app)
      'delete': true,
    },
  },
};

export default rules;
