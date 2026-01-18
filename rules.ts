// InstantDB Rules - defines permissions for data access
const rules = {
  users: {
    $: {
      // Users can read their own data
      'read': (ctx: any, { id }: any) => ctx.auth.id === id,
      // Users can update their own data
      'write': (ctx: any, { id }: any) => ctx.auth.id === id,
      // Users cannot create or delete user records (handled by auth system)
      'create': false,
      'delete': false,
    },
  },
  recipes: {
    $: {
      // Anyone can read recipes (public recipes)
      'read': true,
      // Users can write their own recipes
      'write': (ctx: any, { userId }: any) => ctx.auth.id === userId,
      // Users can create recipes
      'create': (ctx: any, { userId }: any) => ctx.auth.id === userId,
      // Users can delete their own recipes
      'delete': (ctx: any, { userId }: any) => ctx.auth.id === userId,
    },
  },
};

export default rules;
