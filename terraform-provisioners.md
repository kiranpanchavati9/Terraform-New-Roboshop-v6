# Provisioners in Terraform

Provisioners are used to **execute scripts or commands** on a local or remote machine as part of the resource creation or destruction lifecycle.

They act as a "last resort" mechanism to perform actions that can't be handled by Terraform's declarative model alone.

---

## Types of Provisioners

### 1. `local-exec`
Runs a command on the **machine running Terraform** (not the resource).

```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }
}
```

### 2. `remote-exec`
Runs commands **on the remote resource** (e.g., an EC2 instance) via SSH or WinRM.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t2.micro"

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
    ]
  }
}
```

### 3. `file`
Copies files or directories from the local machine **to the remote resource**.

```hcl
resource "aws_instance" "web" {
  provisioner "file" {
    source      = "scripts/setup.sh"
    destination = "/tmp/setup.sh"
  }
}
```

---

## When Provisioners Run

| Trigger | Behavior |
|---|---|
| `on_create` (default) | Runs when the resource is **created** |
| `on_destroy` | Runs when the resource is **destroyed** |

```hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo 'Resource destroyed!'"
}
```

---

## Failure Behavior

```hcl
provisioner "local-exec" {
  command    = "echo hello"
  on_failure = continue  # or "fail" (default)
}
```

- **`fail`** (default) — Marks the resource as tainted and stops apply
- **`continue`** — Ignores the error and continues

---

## Key Considerations

- **Last resort** — HashiCorp recommends avoiding provisioners when possible. Prefer cloud-init, user data scripts, or configuration management tools (Ansible, Chef, Puppet).
- **Not tracked** — Provisioner execution is not stored in Terraform state, so re-running `apply` won't re-run them unless the resource is recreated.
- **Tainted resources** — If a provisioner fails, the resource is marked as *tainted* and will be destroyed/recreated on the next `apply`.
- **`connection` block required** — `remote-exec` and `file` need a `connection` block to define SSH/WinRM credentials.

---

## Connection Block Example

```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t2.micro"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = ["sudo systemctl start nginx"]
  }
}
```

---

## Summary
Provisioners are a powerful escape hatch — but use them sparingly, as they introduce imperative logic into an otherwise declarative workflow.

| Provisioner | Runs On | Use Case |
|---|---|---|
| `local-exec` | Local machine | Trigger scripts, update inventory files |
| `remote-exec` | Remote resource | Install packages, start services |
| `file` | Remote resource | Copy config files or scripts |