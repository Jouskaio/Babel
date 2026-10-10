"""Source plugins: installed by an administrator, switched on by each reader."""

from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, status
from pydantic import BaseModel, Field

from babel_api.api.dependencies import CurrentAdminId, CurrentUserId, PluginServiceDep

router = APIRouter(tags=["plugins"])


class PluginResponse(BaseModel):
    id: UUID
    name: str
    description: str | None
    active: bool = Field(description="You switched it on: it is one of your sources")


class InstallPlugin(BaseModel):
    name: Annotated[str, Field(min_length=1, max_length=120)]
    description: Annotated[str, Field(max_length=500)] | None = None
    url: Annotated[str, Field(min_length=8, max_length=2000, description="The manifest address")]
    token: Annotated[str, Field(max_length=500)] | None = None


@router.get("/plugins", operation_id="listPlugins")
async def list_plugins(user_id: CurrentUserId, plugins: PluginServiceDep) -> list[PluginResponse]:
    """The plugins your administrator installed, and which ones you have on."""
    return [
        PluginResponse(id=p.id, name=p.name, description=p.description, active=on)
        for p, on in await plugins.available(user_id)
    ]


@router.put(
    "/plugins/{plugin_id}/active",
    operation_id="activatePlugin",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def activate_plugin(
    user_id: CurrentUserId, plugins: PluginServiceDep, plugin_id: UUID
) -> None:
    """Switch a plugin on: it becomes one of your sources."""
    await plugins.activate(user_id, plugin_id)


@router.delete(
    "/plugins/{plugin_id}/active",
    operation_id="deactivatePlugin",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def deactivate_plugin(
    user_id: CurrentUserId, plugins: PluginServiceDep, plugin_id: UUID
) -> None:
    """Switch a plugin off: its source goes (the books you imported stay)."""
    await plugins.deactivate(user_id, plugin_id)


@router.post("/admin/plugins", operation_id="installPlugin", status_code=status.HTTP_201_CREATED)
async def install_plugin(
    admin_id: CurrentAdminId, plugins: PluginServiceDep, body: InstallPlugin
) -> PluginResponse:
    """Install a plugin from a manifest address (checked first); readers can then switch it on."""
    plugin = await plugins.install(body.name, body.description, body.url, body.token)
    return PluginResponse(
        id=plugin.id, name=plugin.name, description=plugin.description, active=False
    )


@router.delete(
    "/admin/plugins/{plugin_id}",
    operation_id="uninstallPlugin",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def uninstall_plugin(_: CurrentAdminId, plugins: PluginServiceDep, plugin_id: UUID) -> None:
    """Remove a plugin (the sources readers made from it stay as they are)."""
    await plugins.uninstall(plugin_id)
