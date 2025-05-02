<script lang="ts">
	import UserAuthForm from "./user-auth-form.svelte";
</script>

<div
	class="container relative min-h-screen flex flex-col items-center justify-center md:grid lg:max-w-none lg:grid-cols-2 lg:px-0"
>
	<div class="bg-muted relative hidden h-full flex-col p-10 text-white lg:flex dark:border-r">
		<div
			class="absolute inset-0 bg-cover"
			style="
				background-image:
					url(https://gap-referencement.com/wp-content/uploads/2023/06/Design-sans-titre-19-900x675.png);"
		></div>
	</div>
	<div class="lg:p-8 flex flex-col justify-center w-full">
		<div class="mx-auto flex w-full flex-col justify-center space-y-6 sm:w-[350px]">
			<UserAuthForm />
		</div>
	</div>
</div>
